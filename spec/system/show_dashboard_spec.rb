# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show dashboard', :rack_test do
  include ActionView::Helpers::SanitizeHelper

  context 'when a managing user has works and collections' do
    let!(:work) { create(:work, :with_druid, user:, collection:) }
    let!(:work_without_druid) { create(:work, user:, collection:) }
    let!(:draft_work) { create(:work, :with_druid, user:, collection:) }
    let!(:pending_review_work) do
      create(:work, user:, collection:, review_state: 'pending_review', object_updated_at: 1.day.ago)
    end
    let!(:rejected_review_work) do
      create(:work, user:, collection:, review_state: 'rejected_review', object_updated_at: 1.day.ago)
    end
    let(:shared_work) { create(:work, :with_druid, object_updated_at: 1.day.ago) }
    let(:collection) do
      create(:collection, :with_druid, user:, managers: [user], reviewers: [user], review_enabled: true)
    end
    let(:user) { create(:user) }
    let(:version_status) { build(:accessioning_version_status) }
    let(:draft_version_status) { build(:draft_version_status) }
    let(:banner_text) { strip_links(I18n.t('banner.dashboard_html')) }

    before do
      allow(Sdr::Repository).to receive(:statuses).and_return({ work.druid => version_status,
                                                                draft_work.druid => draft_version_status })
      create(:share, work: shared_work, user:)

      sign_in(user)
    end

    it 'displays the dashboard' do
      visit dashboard_path

      expect(page).to have_css('h1', text: "#{user.name} - Dashboard")

      expect(page).to have_css('meta[name="turbo-cache-control"][content="no-preview"]', visible: :hidden)

      expect(page).to have_no_link('Admin')

      if banner_text.present?
        expect(page).to have_css('.alert.alert-info', text: banner_text)
      else
        expect(page).to have_no_css('.alert.alert-info')
      end

      # Drafts section
      expect(page).to have_css('h2', text: 'Drafts - please complete')
      within('table#drafts-table') do
        expect(page).to have_css('td', text: draft_work.title)
        expect(page).to have_no_css('td', text: pending_review_work.title)
        expect(page).to have_css('td', text: rejected_review_work.title)
      end

      # Pending review section
      expect(page).to have_css('h2', text: 'Items waiting for collection manager or reviewer to approve')
      within('table#pending-review-table') do
        expect(page).to have_css('td', text: pending_review_work.title)
      end

      # Shared works section
      expect(page).to have_css('h2', text: 'Items shared with you')
      within('table#shares-table') do
        expect(page).to have_css('td', text: shared_work.title)
      end

      # Your collections section
      expect(page).to have_css('h2', text: 'Your collections')
      expect(page).to have_css('h3', text: collection.title)
      expect(page).to have_no_css('.alert', text: 'Congratulations on taking the first step')

      # Works table
      within("table#table_collection_#{collection.id}") do
        within("tr#table_collection_#{collection.id}_work_#{work.id}") do
          expect(page).to have_css('td', text: work.title)
          expect(page).to have_css('td', text: 'Depositing')
        end
        within("tr#table_collection_#{collection.id}_work_#{work_without_druid.id}") do
          expect(page).to have_css('td', text: work_without_druid.title)
          expect(page).to have_css('td', text: 'Saving')
        end
        within("tr#table_collection_#{collection.id}_work_#{draft_work.id}") do
          expect(page).to have_css('td', text: draft_work.title)
          expect(page).to have_css('td', text: 'New version in draft')
        end
      end
    end
  end

  context 'when a depositor has draft and pending review works' do
    let!(:work) { create(:work, :with_druid, user:, collection:) }
    let!(:draft_work) { create(:work, :with_druid, user:, collection:) }
    let!(:pending_review_work) { create(:work, user:, collection:, review_state: 'pending_review') }
    let(:collection) { create(:collection, :with_druid, depositors: [user], review_enabled: true) }
    let(:user) { create(:user) }
    let(:version_status) { build(:accessioning_version_status) }
    let(:draft_version_status) { build(:draft_version_status) }
    let(:pending_review_version_status) { build(:first_draft_version_status) }
    let(:banner_text) { strip_links(I18n.t('banner.dashboard_html')) }

    before do
      allow(Sdr::Repository).to receive(:statuses).and_return({ work.druid => version_status,
                                                                draft_work.druid => draft_version_status,
                                                                pending_review_work.druid => pending_review_version_status }) # rubocop:disable Layout/LineLength
      sign_in(user)
    end

    it 'displays the dashboard' do
      visit dashboard_path

      expect(page).to have_css('h1', text: "#{user.name} - Dashboard")

      expect(page).to have_css('meta[name="turbo-cache-control"][content="no-preview"]', visible: :hidden)

      expect(page).to have_no_link('Admin')

      if banner_text.present?
        expect(page).to have_css('.alert.alert-info', text: banner_text)
      else
        expect(page).to have_no_css('.alert.alert-info')
      end

      # Drafts section
      expect(page).to have_css('h2', text: 'Drafts - please complete')
      within('table#drafts-table') do
        expect(page).to have_css('td', text: draft_work.title)
        expect(page).to have_no_css('td', text: pending_review_work.title)
      end

      # Your collections section
      expect(page).to have_css('h2', text: 'Your collections')
      expect(page).to have_css('h3', text: collection.title)
      expect(page).to have_no_css('.alert', text: 'Congratulations on taking the first step')

      # Works table
      within("table#table_collection_#{collection.id}") do
        within("tr#table_collection_#{collection.id}_work_#{work.id}") do
          expect(page).to have_css('td', text: work.title)
          expect(page).to have_css('td', text: 'Depositing')
        end
        within("tr#table_collection_#{collection.id}_work_#{draft_work.id}") do
          expect(page).to have_css('td', text: draft_work.title)
          expect(page).to have_css('td', text: 'New version in draft')
        end
        within("tr#table_collection_#{collection.id}_work_#{pending_review_work.id}") do
          expect(page).to have_css('td', text: pending_review_work.title)
          expect(page).to have_css('td', text: 'Pending review')
        end
      end
    end
  end

  context 'when new user' do
    let!(:work) do
      create(:work, :with_druid, user:).tap do |work|
        create(:share, work:, user:)
      end
    end
    let(:user) { create(:user) }

    before do
      allow(Sdr::Repository).to receive(:statuses).and_return({})

      sign_in(user)
    end

    it 'when new user with shares but not collections' do
      visit dashboard_path

      expect(page).to have_css('h1', text: "#{user.name} - Dashboard")

      expect(page).to have_no_css('h2', text: 'Drafts - please complete')
      expect(page).to have_no_css('h2', text: 'Items waiting for collection manager or reviewer to approve')
      expect(page).to have_no_css('h2', text: 'Your collections')

      # Your collections section
      expect(page).to have_css('h2', text: 'Items shared with you')
      within('table#shares-table') do
        expect(page).to have_css('td', text: work.title)
      end
    end
  end

  context 'when new user with shares but not collections' do
    let!(:collection) { create(:collection, :with_druid, depositors: [user]) }
    let(:user) { create(:user) }

    before do
      sign_in(user)
    end

    it 'shows the dashboard' do
      visit dashboard_path

      expect(page).to have_css('h1', text: "#{user.name} - Dashboard")

      expect(page).to have_no_css('h2', text: 'Drafts - please complete')
      expect(page).to have_no_css('h2', text: 'Items waiting for collection manager or reviewer to approve')

      # Your collections section
      expect(page).to have_css('h2', text: 'Your collections')
      expect(page).to have_css('h3', text: collection.title)

      expect(page).to have_css('.alert', text: 'Congratulations on taking the first step')
    end
  end
end
