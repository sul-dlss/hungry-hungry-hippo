# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Admin::CollectionReport do
  include CollectionMappingFixtures
  include WorkMappingFixtures

  subject(:csv) { described_class.call(collection_report_form:) }

  let(:user) { User.new(email_address: 'testuser@stanford.edu') }
  let(:druid) { collection_druid_fixture }
  let!(:collection) { create(:collection, druid:) }
  let(:druid2) { 'druid:cc345dd6789' }
  let(:collection_report_form) do
    Admin::CollectionReportForm.new(date_created_start: nil,
                                    date_created_end: nil,
                                    date_modified_start: nil,
                                    date_modified_end: nil)
  end
  let(:collection_cocina_object) { collection_with_metadata_fixture }
  let(:collection2_cocina_object) do
    collection_with_metadata_fixture.new(externalIdentifier: druid2,
                                         description: { title: [{ value: 'Another Collection' }],
                                                        purl: Sdr::Purl.from_druid(druid: druid2) })
  end
  let(:version_status) { build(:version_status) }
  let(:csv_data) { CSV.parse(csv, headers: true) }

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(collection_cocina_object)
    allow(Sdr::Repository).to receive(:find).with(druid: druid2).and_return(collection2_cocina_object)
    allow(Sdr::Repository).to receive(:status).with(druid:).and_return(version_status)
    allow(Sdr::Repository).to receive(:status).with(druid: druid2).and_return(version_status)
    allow(Current).to receive(:user).and_return(user)
  end

  describe '.call' do
    context 'when no form filters are applied' do
      it 'returns a csv with all collections' do
        expect(csv).to include(druid)
        expect(csv).to include('My Collection')
        # 23 headers
        expect(csv.split("\n").first.split(',').count).to eq(23)
      end
    end

    context 'when the collection has works' do
      # let(:collection_with_works) { create(:collection, druid: druid2) }
      let(:cocina_object) { dro_with_metadata_fixture }
      let(:version_status) { build(:draft_version_status) }
      let(:object_client) { instance_double(Dor::Services::Client::Object, find: cocina_object) }

      before do
        allow(Sdr::Repository).to receive(:find).with(druid: druid_fixture).and_return(cocina_object)
        allow(Sdr::Repository).to receive(:status).with(druid: druid_fixture).and_return(version_status)
        allow(Dor::Services::Client).to receive(:object).with(druid).and_return(object_client)
        create(:work, druid: druid_fixture, collection:)
      end

      it 'returns a csv with all collections including work stats' do
        expect(csv_data['collection druid']).to eq([druid])
        expect(csv_data['collection title']).to eq(['My Collection'])
        expect(csv_data['works count']).to eq(['1'])
        expect(csv_data['draft count']).to eq(['1'])
      end
    end

    context 'when filtering by date_created_start' do
      before do
        allow(Sdr::Repository).to receive(:statuses).with(druids: []).and_return({})
      end

      let(:date_created_start) { Date.tomorrow }
      let(:collection_report_form) do
        Admin::CollectionReportForm.new(date_created_start:,
                                        date_created_end: nil,
                                        date_modified_start: nil,
                                        date_modified_end: nil)
      end

      it 'does not include collections created before the start date' do
        expect(csv_data[:druid]).not_to include(druid)
      end
    end

    context 'when filtering by date_created_end' do
      let(:date_created_end) { Date.yesterday }
      let(:collection_report_form) do
        Admin::CollectionReportForm.new(date_created_start: nil,
                                        date_created_end:,
                                        date_modified_start: nil,
                                        date_modified_end: nil)
      end

      before do
        create(:collection, druid: druid2, created_at: 2.days.ago)
      end

      it 'does not include works created after the start date' do
        expect(csv_data['collection druid']).to eq([druid2])
      end
    end

    context 'when filtering by date_modified_start' do
      let(:date_modified_start) { Date.tomorrow }
      let(:collection_report_form) do
        Admin::CollectionReportForm.new(date_created_start: nil,
                                        date_created_end: nil,
                                        date_modified_start:,
                                        date_modified_end: nil)
      end

      before do
        create(:collection, druid: druid2, object_updated_at: 3.days.from_now)
      end

      it 'does not include works created before the start date' do
        expect(csv_data['collection druid']).to eq([druid2])
      end
    end

    context 'when filtering by date_modified_end' do
      let(:date_modified_end) { Date.yesterday }
      let(:collection_report_form) do
        Admin::WorkReportForm.new(date_created_start: nil,
                                  date_created_end: nil,
                                  date_modified_start: nil,
                                  date_modified_end:)
      end

      before do
        create(:collection, druid: druid2, object_updated_at: 3.days.ago)
      end

      it 'does not include collections modified after the start date' do
        expect(csv_data['collection druid']).to eq([druid2])
      end
    end
  end
end
