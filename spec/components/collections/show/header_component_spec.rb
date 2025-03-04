# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::Show::HeaderComponent, type: :component do
  let(:presenter) do
    CollectionPresenter.new(collection_form:, version_status:, collection:, work_statuses: [])
  end
  let(:collection_form) { CollectionForm.new(druid: druid_fixture, title:) }
  let(:collection) { create(:collection, user:, druid: druid_fixture) }
  let(:user) { create(:user) }
  let(:version_status) do
    instance_double(VersionStatus, editable?: editable, first_draft?: first_draft)
  end
  let(:title) { 'My Collection Title' }
  let(:editable) { false }
  let(:first_draft) { false }

  before do
    allow(vc_test_controller).to receive(:current_user).and_return(user)
    allow(Current).to receive(:groups).and_return([])
  end

  it 'renders the header' do
    render_inline(described_class.new(presenter:))
    expect(page).to have_css('h1', text: title)
    expect(page).to have_no_link('Edit')
    expect(page).to have_no_button('Discard draft')
    expect(page).to have_no_button('Admin functions')
    expect(page).to have_no_button('Deposit to this collection')
  end

  context 'when editable' do
    let(:editable) { true }

    it 'renders the edit button' do
      render_inline(described_class.new(presenter:))
      expect(page).to have_link('Edit', href: "/collections/#{druid_fixture}/edit")
      expect(page).to have_link(href: "/collections/#{druid_fixture}/edit")
    end
  end

  context 'when a first draft' do
    let(:first_draft) { true }
    let(:editable) { true }
    let(:discardable) { true }
    let(:version_status) do
      instance_double(VersionStatus, editable?: editable, discardable?: discardable, first_draft?: first_draft)
    end

    it 'does not show the Deposit to collection button' do
      render_inline(described_class.new(presenter:))
      expect(page).to have_no_button('Deposit to this collection')
    end
  end

  context 'when the user is not allowed to deposit' do
    let(:manager) { create(:user) }
    let(:first_draft) { true }
    let(:collection) { create(:collection, user: manager, druid: druid_fixture) }

    before do
      allow(vc_test_controller).to receive(:current_user).and_return(user)
      allow(Current).to receive(:groups).and_return([])
    end

    it 'does not show the Deposit to this collection button' do
      render_inline(described_class.new(presenter:))
      expect(page).to have_css('h1', text: title)
      expect(page).to have_no_link('Edit')
      expect(page).to have_no_button('Discard draft')
      expect(page).to have_no_button('Deposit to this collection')
    end
  end

  context 'when the user is an admin' do
    let(:groups) { ['dlss:hydrus-app-administrators'] }

    before do
      allow(vc_test_controller).to receive(:current_user).and_return(user)
      allow(Current).to receive(:groups).and_return(groups)
    end

    it 'shows the Deposit to this collection button' do
      render_inline(described_class.new(presenter:))
      expect(page).to have_button('Admin functions')
      expect(page).to have_link('Delete', class: 'dropdown-item')
    end
  end
end
