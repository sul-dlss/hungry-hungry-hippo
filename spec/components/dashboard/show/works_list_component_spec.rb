# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Dashboard::Show::WorksListComponent, type: :component do
  let(:work) do
    create(:work, user: current_user, collection:, druid: druid_fixture,
                  object_updated_at: Time.zone.parse('2024-12-3'), doi_assigned: false)
  end
  let(:work_without_druid) { create(:work, user: current_user, collection:) }
  let(:work_in_collection) { create(:work, :with_druid, user: work_in_collection_user, collection:) }
  let(:work_with_doi) { create(:work, :with_druid, user: current_user, collection:) }
  let(:work_in_review) { create(:work, :with_druid, user: current_user, collection:, review_state: 'pending_review') }
  let(:collection) { create(:collection, druid: collection_druid_fixture, depositors: [current_user]) }
  let(:current_user) { create(:user) }
  let(:status_map) do
    {
      work.id => build(:first_draft_version_status),
      work_without_druid.id => VersionStatus::NilStatus.new,
      work_in_collection.id => VersionStatus::NilStatus.new,
      work_with_doi.id => VersionStatus::NilStatus.new,
      work_in_review.id => VersionStatus::NilStatus.new
    }
  end

  before do
    allow(vc_test_controller).to receive(:current_user).and_return(current_user)
    allow(Current).to receive(:groups).and_return([])
  end

  context 'when there are <= 4 works' do
    # This means that work_in_collection will be owned by a different user and therefore not shown.
    let(:work_in_collection_user) { create(:user) }

    it 'renders the works list table with rows' do
      render_inline(described_class.new(collection:, status_map:))

      table = page.find('table')
      expect(table).to have_css('th', text: 'Recent deposits in collection')
      expect(table).to have_css('th', text: 'Deposit status')
      expect(table).to have_css('th', text: 'Owner')
      expect(table).to have_css('th', text: 'Last modified')
      expect(table).to have_css('th', text: 'Link for sharing')
      table_body = table.find('tbody')
      expect(table_body).to have_css('tr', count: 4)
      first_row = table_body.find('tr:nth-of-type(1)')
      expect(first_row).to have_css('td:nth-of-type(1)', text: work.title)
      expect(first_row).to have_link(work.title, href: "/works/#{work.druid}")
      expect(first_row).to have_css('td:nth-of-type(2)', text: 'Draft - Not deposited')
      expect(first_row).to have_css('td:nth-of-type(4)', text: 'Dec 03, 2024')
      expect(first_row).to have_css('td:nth-of-type(5)', text: Sdr::Purl.from_druid(druid: work.druid))
      second_row = table_body.find('tr:nth-of-type(2)')
      expect(second_row).to have_css('td:nth-of-type(1)', text: work_without_druid.title)
      expect(second_row).to have_link(work_without_druid.title, href: "/works/wait/#{work_without_druid.id}")
      expect(second_row).to have_css('td:nth-of-type(2)', text: 'Saving')
      expect(second_row).to have_css('td:nth-of-type(5)', text: '') # No PURL
      third_row = table_body.find('tr:nth-of-type(3)')
      expect(third_row).to have_css('td:nth-of-type(5)', text: Doi.url(druid: work_with_doi.druid))
      fourth_row = table_body.find('tr:nth-of-type(4)')
      expect(fourth_row).to have_css('td:nth-of-type(2)', text: 'Pending review')

      expect(page).to have_no_link('See all deposits')
    end
  end

  context 'when there are > 4 works' do
    # This means that work_in_collection will be shown.
    let(:work_in_collection_user) { current_user }

    it 'renders the works list table with rows' do
      render_inline(described_class.new(collection:, status_map:))

      expect(page).to have_css('table tbody tr', count: 4)
      expect(page).to have_link('See all deposits', href: "/collections/#{collection.druid}?tab=deposits")
    end
  end
end
