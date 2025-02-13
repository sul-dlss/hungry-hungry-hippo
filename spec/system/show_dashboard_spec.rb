# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Show dashboard', :rack_test do
  context 'when existing user has works and collections' do
    let!(:work) { create(:work, :with_druid, user:, collection:) }
    let!(:work_without_druid) { create(:work, user:, collection:) }
    let!(:draft_work) { create(:work, :with_druid, user:, collection:) }
    let!(:pending_review_work) { create(:work, user:, collection:, review_state: 'pending_review') }
    let(:collection) do
      create(:collection, :with_druid, user:, managers: [user], reviewers: [user], review_enabled: true)
    end
    let(:user) { create(:user) }
    let(:version_status) { build(:accessioning_version_status) }
    let(:draft_version_status) { build(:draft_version_status) }

    before do
      allow(Sdr::Repository).to receive(:statuses).and_return({ work.druid => version_status,
                                                                draft_work.druid => draft_version_status })
      sign_in(user)
    end

    it 'displays the dashboard' do
      visit dashboard_path

      expect(page).to have_css('h2', text: "#{user.name} - Dashboard")

      # Drafts section
      expect(page).to have_css('h3', text: 'Drafts - please complete')
      within('table#drafts-table') do
        expect(page).to have_css('td', text: draft_work.title)
      end

      # Pending review section
      expect(page).to have_css('h3', text: 'Items waiting for collection manager or reviewer to approve')
      within('table#pending-review-table') do
        expect(page).to have_css('td', text: pending_review_work.title)
      end

      # Your collections section
      expect(page).to have_css('h3', text: 'Your collections')
      expect(page).to have_css('h4', text: collection.title)
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

  context 'when new user' do
    let!(:collection) { create(:collection, :with_druid, depositors: [user]) }
    let(:user) { create(:user) }

    before do
      sign_in(user)
    end

    it 'shows the dashboard' do
      visit dashboard_path

      expect(page).to have_css('h2', text: "#{user.name} - Dashboard")

      expect(page).to have_no_css('h3', text: 'Drafts - please complete')
      expect(page).to have_no_css('h3', text: 'Items waiting for collection manager or reviewer to approve')

      # Your collections section
      expect(page).to have_css('h3', text: 'Your collections')
      expect(page).to have_css('h4', text: collection.title)

      expect(page).to have_css('.alert', text: 'Congratulations on taking the first step')
    end
  end
end
