# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Admin::WorkReport do
  include WorkMappingFixtures

  subject(:csv) { described_class.call(work_report_form:) }

  let(:user) { User.new(email_address: 'testuser@stanford.edu') }
  let(:druid) { druid_fixture }
  let(:druid2) { 'druid:bc000dd1111' }
  let(:druid_list) { [druid2, druid] }
  let(:work_report_form) do
    Admin::WorkReportForm.new(date_created_start: nil, date_created_end: nil, date_modified_start: nil,
                              date_modified_end: nil, collection_ids: [''], draft_not_deposited_state: false,
                              pending_review_state: false, returned_state: false,
                              deposit_in_progress_state: false, deposited_state: false,
                              version_draft_state: false)
  end
  let(:version_status) { build(:version_status) }
  let(:version_status2) { build(:version_status) }
  let(:cocina_object) do
    dro_with_metadata_fixture.new(externalIdentifier: druid,
                                  description: { title: [{ value: 'Test Work' }],
                                                 form: [{ structuredValue: [
                                                            {
                                                              value: 'Mixed Materials',
                                                              type: 'type'
                                                            },
                                                            {
                                                              value: 'Government document',
                                                              type: 'subtype'
                                                            }
                                                          ],
                                                          source: {
                                                            value: 'Stanford self-deposit resource types'
                                                          },
                                                          type: 'resource type' }],
                                                 purl: Sdr::Purl.from_druid(druid:) })
  end
  let(:cocina_object2) do
    dro_with_metadata_fixture.new(externalIdentifier: druid2,
                                  description: { title: [{ value: 'Another Work' }],
                                                 purl: Sdr::Purl.from_druid(druid: druid2) })
  end

  before do
    create(:work, druid:)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    allow(Sdr::Repository).to receive(:status).with(druid: druid2).and_return(version_status2)
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Sdr::Repository).to receive(:find).with(druid: druid2).and_return(cocina_object2)
    allow(Current).to receive(:user).and_return(user)
  end

  describe '.call' do
    context 'when no form filters are applied' do
      before do
        create(:work, druid: druid2)
      end

      it 'returns a csv with all works' do
        expect(csv).to include(druid, druid2)
        expect(csv).to include('Test Work', 'Another Work')
        expect(csv).to include('Mixed Materials')
      end
    end

    context 'when filtering by date_created_start' do
      before do
        create(:work, druid: druid2)
        allow(Sdr::Repository).to receive(:statuses).with(druids: []).and_return({})
      end

      let(:date_created_start) { Date.tomorrow }
      let(:work_report_form) do
        Admin::WorkReportForm.new(date_created_start:, date_created_end: nil, date_modified_start: nil,
                                  date_modified_end: nil, collection_ids: [''], draft_not_deposited_state: false,
                                  pending_review_state: false, returned_state: false,
                                  deposit_in_progress_state: false, deposited_state: false,
                                  version_draft_state: false)
      end

      it 'does not include works created before the start date' do
        expect(csv).not_to include(druid)
      end
    end

    context 'when filtering by date_created_end' do
      let(:date_created_end) { Date.yesterday }
      let(:work_report_form) do
        Admin::WorkReportForm.new(date_created_start: nil, date_created_end:, date_modified_start: nil,
                                  date_modified_end: nil, collection_ids: [''], draft_not_deposited_state: false,
                                  pending_review_state: false, returned_state: false,
                                  deposit_in_progress_state: false, deposited_state: false,
                                  version_draft_state: false)
      end

      before do
        create(:work, druid: druid2, created_at: 2.days.ago)
      end

      it 'does not include works created after the start date' do
        expect(csv).not_to include(druid)
        expect(csv).to include(druid2)
      end
    end

    context 'when filtering by date_modified_start' do
      let(:date_modified_start) { Date.tomorrow }
      let(:work_report_form) do
        Admin::WorkReportForm.new(date_created_start: nil, date_created_end: nil, date_modified_start:,
                                  date_modified_end: nil, collection_ids: [''], draft_not_deposited_state: false,
                                  pending_review_state: false, returned_state: false,
                                  deposit_in_progress_state: false, deposited_state: false,
                                  version_draft_state: false)
      end

      before do
        create(:work, druid: druid2, object_updated_at: 3.days.from_now)
      end

      it 'does not include works created before the start date' do
        expect(csv).not_to include(druid)
        expect(csv).to include(druid2)
      end
    end

    context 'when filtering by date_modified_end' do
      let(:date_modified_end) { Date.yesterday }
      let(:work_report_form) do
        Admin::WorkReportForm.new(date_created_start: nil, date_created_end: nil, date_modified_start: nil,
                                  date_modified_end:, last_deposited_start: nil, last_deposited_end: nil,
                                  collection_ids: [], draft_not_deposited_state: false,
                                  pending_review_state: false, returned_state: false,
                                  deposit_in_progress_state: false, deposited_state: false,
                                  version_draft_state: false)
      end

      before do
        create(:work, druid: druid2, object_updated_at: 3.days.ago)
      end

      it 'does not include works modified after the start date' do
        expect(csv).not_to include(druid)
        expect(csv).to include(druid2)
      end
    end

    context 'when filtering by last_deposited_start' do
      let(:last_deposited_start) { Time.zone.tomorrow }
      let(:work_report_form) do
        Admin::WorkReportForm.new(date_created_start: nil, date_created_end: nil, date_modified_start: nil,
                                  date_modified_end: nil, last_deposited_start:, last_deposited_end: nil,
                                  collection_ids: [''], draft_not_deposited_state: false,
                                  pending_review_state: false, returned_state: false,
                                  deposit_in_progress_state: false, deposited_state: false,
                                  version_draft_state: false)
      end

      before do
        create(:work, druid: druid2)
        allow(Sdr::Repository).to receive(:statuses).with(druids: []).and_return({})
      end

      it 'does not include works created before the start date' do
        expect(csv).not_to include(druid)
      end
    end

    context 'when filtering by last_deposited_end' do
      let(:last_deposited_end) { Time.zone.yesterday }
      let(:work_report_form) do
        Admin::WorkReportForm.new(date_created_start: nil, date_created_end: nil, date_modified_start: nil,
                                  date_modified_end: nil, last_deposited_start: nil, last_deposited_end:,
                                  collection_ids: [''], draft_not_deposited_state: false,
                                  deposit_in_progress_state: false, deposited_state: false,
                                  version_draft_state: false, pending_review_state: false, returned_state: false)
      end

      before do
        create(:work, druid: druid2, created_at: 2.days.ago, last_deposited_at: 2.days.ago)
      end

      it 'does not include works deposited after the start date' do
        expect(csv).not_to include(druid)
        expect(csv).to include(druid2)
      end
    end

    context 'when filtering by collection' do
      let(:collection2) { create(:collection) }
      let(:work_report_form) do
        Admin::WorkReportForm.new(date_created_start: nil, date_created_end: nil, date_modified_start: nil,
                                  date_modified_end: nil, collection_ids: ['', collection2.id],
                                  draft_not_deposited_state: false, pending_review_state: false, returned_state: false,
                                  deposit_in_progress_state: false, deposited_state: false,
                                  version_draft_state: false)
      end

      before do
        create(:work, druid: druid2, collection: collection2)
      end

      it 'includes work in the selected collection' do
        expect(csv).not_to include(druid)
        expect(csv).to include(druid2)
      end
    end

    context 'when filtering by draft_not_deposited_state' do
      let(:work_report_form) do
        Admin::WorkReportForm.new(date_created_start: nil, date_created_end: nil, date_modified_start: nil,
                                  date_modified_end: nil, collection_ids: [''], draft_not_deposited_state: true,
                                  pending_review_state: false, returned_state: false,
                                  deposit_in_progress_state: false, deposited_state: false,
                                  version_draft_state: false)
      end
      let(:version_status2) { build(:first_draft_version_status) }

      before do
        create(:work, druid: druid2)
      end

      it 'includes work in draft_not_deposited state' do
        expect(csv).not_to include(druid)
        expect(csv).to include(druid2)
      end
    end

    context 'when filtering by returned state' do
      let(:work_report_form) do
        Admin::WorkReportForm.new(date_created_start: nil, date_created_end: nil, date_modified_start: nil,
                                  date_modified_end: nil, collection_ids: [''], draft_not_deposited_state: nil,
                                  pending_review_state: false, returned_state: true,
                                  deposit_in_progress_state: false, deposited_state: false,
                                  version_draft_state: false)
      end

      before do
        create(:work, :rejected_review, druid: druid2)
      end

      it 'includes work in returned state' do
        expect(csv).not_to include(druid)
        expect(csv).to include(druid2)
      end
    end

    context 'when filtering by deposit_in_progess_state' do
      let(:work_report_form) do
        Admin::WorkReportForm.new(date_created_start: nil, date_created_end: nil, date_modified_start: nil,
                                  date_modified_end: nil, last_deposited_start: nil, last_deposited_end: nil,
                                  collection_ids: [''], draft_not_deposited_state: false,
                                  deposit_in_progress_state: true, deposited_state: false,
                                  version_draft_state: false, pending_review_state: false, returned_state: false)
      end
      let(:version_status2) { build(:accessioning_version_status) }

      before do
        create(:work, druid: druid2)
      end

      it 'includes work in deposit in progress state' do
        expect(csv).not_to include(druid)
        expect(csv).to include(druid2)
      end
    end

    context 'when filtering by deposited_state' do
      let(:work_report_form) do
        Admin::WorkReportForm.new(date_created_start: nil, date_created_end: nil, date_modified_start: nil,
                                  date_modified_end: nil, last_deposited_start: nil, last_deposited_end: nil,
                                  collection_ids: [''], draft_not_deposited_state: false,
                                  pending_review_state: false, returned_state: false, deposit_in_progress_state: false,
                                  deposited_state: true, version_draft_state: false)
      end

      before do
        create(:work, druid: druid2)
      end

      it 'includes works in deposited state' do
        expect(csv).to include(druid)
        expect(csv).to include(druid2)
      end
    end

    context 'when work has multiple states that match selected states' do
      let(:work_report_form) do
        Admin::WorkReportForm.new(date_created_start: nil, date_created_end: nil, date_modified_start: nil,
                                  date_modified_end: nil, collection_ids: [''],
                                  last_deposited_start: nil, last_deposited_end: nil,
                                  pending_review_state: true, returned_state: false,
                                  draft_not_deposited_state: false, deposit_in_progress_state: false,
                                  deposited_state: false, version_draft_state: true)
      end
      let(:version_status2) { build(:draft_version_status) }

      before do
        create(:work, druid: druid2, review_state: 'pending_review')
      end

      it 'includes work once with both statuses' do
        expect(csv).not_to include(druid)
        expect(csv.scan(druid2).count).to eq(1)
        expect(csv).to include('Pending review')
        expect(csv).to include('New version in draft')
      end
    end

    context 'when DOI assigned' do
      before do
        create(:work, druid: druid2)
      end

      it 'includes doi' do
        expect(csv).to include(doi_fixture)
      end
    end

    context 'when DOI not assigned' do
      let(:collection2) { create(:collection) }
      let(:work_report_form) do
        Admin::WorkReportForm.new(date_created_start: nil, date_created_end: nil, date_modified_start: nil,
                                  date_modified_end: nil, collection_ids: ['', collection2.id],
                                  last_deposited_start: nil, last_deposited_end: nil,
                                  pending_review_state: true, returned_state: false,
                                  draft_not_deposited_state: false, deposit_in_progress_state: false,
                                  deposited_state: false, version_draft_state: true)
      end

      before do
        create(:work, druid: druid2, collection: collection2, doi_assigned: false)
      end

      it 'does not include DOI' do
        expect(csv).not_to include(doi_fixture)
      end
    end

    context 'when work is not found in SDR' do
      before do
        create(:work, druid: druid2)
        allow(Sdr::Repository).to receive(:find).with(druid: druid2).and_raise(Sdr::Repository::NotFoundResponse)
        allow(Honeybadger).to receive(:notify)
      end

      it 'returns a csv without the missing work' do
        expect(csv).to include(druid)
        expect(csv).not_to include(druid2)
        expect(csv).to include('Test Work')
        expect(csv).not_to include('Another Work')
        expect(Honeybadger).to have_received(:notify)
          .with('Error looking up work in SDR. This may be a draft work that was purged via Argo.',
                context: {
                  druid: druid2,
                  exception: Sdr::Repository::NotFoundResponse
                })
      end
    end
  end
end
