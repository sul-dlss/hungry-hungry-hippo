# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Works::Show::HeaderComponent, type: :component do
  let(:presenter) do
    WorkPresenter.new(work_form:, version_status:, work:)
  end
  let(:work_form) { WorkForm.new(druid: druid_fixture, title:) }
  let(:work) { create(:work, review_state:, user: owner) }
  let(:version_status) do
    instance_double(VersionStatus, editable?: editable_version_status, discardable?: discardable_version_status,
                                   status_message:)
  end
  let(:title) { 'My Title' }
  let(:status_message) { 'Depositing' }
  let(:editable_version_status) { false }
  let(:discardable_version_status) { false }
  let(:review_state) { 'review_not_in_progress' }

  let(:user) { build(:user) }
  let(:owner) { build(:user) }
  let(:groups) { [] }
  let(:permission) { 'edit' }

  before do
    allow(vc_test_controller).to receive(:current_user).and_return(user)
    allow(Current).to receive_messages(groups:, user:)

    create(:share, work:, user:, permission:)
  end

  it 'renders the header' do
    render_inline(described_class.new(presenter:))
    expect(page).to have_css('h1', text: title)
    expect(page).to have_css('.status', text: status_message)
    expect(page).to have_no_link('Edit or deposit')
    expect(page).to have_no_button('Discard draft')
  end

  context 'when editable version status and user has permissions to edit' do
    let(:editable_version_status) { true }

    it 'renders the edit button' do
      render_inline(described_class.new(presenter:))
      expect(page).to have_link('Edit or deposit', href: "/works/#{druid_fixture}/edit")
    end
  end

  context 'when editable version status and user does not have permissions to edit' do
    let(:editable_version_status) { true }
    let(:permission) { 'view' }

    it 'does not render the edit button' do
      render_inline(described_class.new(presenter:))
      expect(page).to have_no_link('Edit or deposit')
    end
  end

  context 'when pending review' do
    let(:editable_version_status) { true }
    let(:review_state) { 'pending_review' }

    it 'does not render the edit button' do
      render_inline(described_class.new(presenter:))
      expect(page).to have_no_link('Edit or deposit')
    end
  end

  context 'when pending review but user is collection manager' do
    let(:editable_version_status) { true }
    let(:review_state) { 'pending_review' }

    before do
      work.collection.managers = [user]
      work.collection.save!
    end

    it 'renders the edit button' do
      render_inline(described_class.new(presenter:))
      expect(page).to have_link('Edit or deposit')
    end
  end

  context 'when discardable and user has permissions to discard' do
    let(:discardable_version_status) { true }
    let(:owner) { user } # Owner can discard

    it 'renders the discard button' do
      render_inline(described_class.new(presenter:))
      expect(page).to have_button('Discard draft')
      expect(page).to have_css("form[action=\"/works/#{druid_fixture}\"]")
      expect(page).to have_field('_method', with: 'delete', type: :hidden)
    end
  end

  context 'when discardable and user does not have permissions to discard' do
    let(:discardable_version_status) { true }

    it 'does not render the discard button' do
      render_inline(described_class.new(presenter:))
      expect(page).to have_no_button('Discard draft')
    end
  end

  context 'when user is an admin' do
    let(:groups) { ['dlss:hydrus-app-administrators'] }
    let(:editable_version_status) { true }

    it 'renders the admin functions button' do
      render_inline(described_class.new(presenter:))

      expect(page).to have_button('Admin functions')
      expect(page).to have_link('Move to another collection', class: 'dropdown-item')
      expect(page).to have_link('Delete', class: 'dropdown-item')
      expect(page).to have_link('Edit or deposit', href: "/works/#{druid_fixture}/edit")
      expect(page).to have_css("turbo-frame[id='admin-card']")
    end
  end
end
