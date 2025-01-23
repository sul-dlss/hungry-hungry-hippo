# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collections::Show::HeaderComponent, type: :component do
  let(:presenter) do
    CollectionPresenter.new(collection_form:, version_status:, collection:)
  end
  let(:collection_form) { CollectionForm.new(druid: druid_fixture, title:) }
  let(:collection) { create(:collection, user:, druid: druid_fixture) }
  let(:user) { create(:user) }
  let(:version_status) do
    instance_double(VersionStatus, editable?: editable, discardable?: discardable, first_draft?: first_draft,
                                   status_message:)
  end
  let(:title) { 'My Collection Title' }
  let(:status_message) { 'Depositing' }
  let(:editable) { false }
  let(:discardable) { false }
  let(:first_draft) { false }

  before do
    allow(vc_test_controller).to receive(:current_user).and_return(user)
    allow(Current).to receive(:groups).and_return([])
  end

  it 'renders the header' do
    render_inline(described_class.new(presenter:))
    expect(page).to have_css('h1', text: title)
    expect(page).to have_css('.status', text: status_message)
    expect(page).to have_no_link('Edit or deposit')
    expect(page).to have_no_button('Discard draft')
    expect(page).to have_no_button('Deposit to this collection')
    expect(page).to have_no_css('i.bi-pencil')
  end

  context 'when editable' do
    let(:editable) { true }

    it 'renders the edit button' do
      render_inline(described_class.new(presenter:))
      expect(page).to have_link('Edit or deposit', href: "/collections/#{druid_fixture}/edit")
      expect(page).to have_css('i.bi-pencil.h4')
      expect(page).to have_link(href: "/collections/#{druid_fixture}/edit")
    end
  end

  context 'when discardable' do
    let(:discardable) { true }

    it 'renders the discard button' do
      render_inline(described_class.new(presenter:))
      expect(page).to have_button('Discard draft')
      expect(page).to have_css("form[action=\"/collections/#{druid_fixture}\"]")
      expect(page).to have_field('_method', with: 'delete', type: :hidden)
    end
  end

  context 'when a first draft' do
    let(:first_draft) { true }
    let(:editable) { true }
    let(:discardable) { true }
    let(:version_status) do
      instance_double(VersionStatus, editable?: editable, discardable?: discardable, first_draft?: first_draft,
                                     status_message:)
    end

    it 'does not show the Deposit to collection button' do
      render_inline(described_class.new(presenter:))
      expect(page).to have_no_button('Deposit to this collection')
      expect(page).to have_css('i.bi-pencil.h4')
    end
  end

  context 'the user is not allowed to deposit' do
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
      expect(page).to have_no_link('Edit or deposit')
      expect(page).to have_no_button('Discard draft')
      expect(page).to have_no_button('Deposit to this collection')
      expect(page).to have_no_css('i.bi-pencil')
    end
  end
end
