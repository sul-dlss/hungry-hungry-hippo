# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Importers::Collection do
  include CollectionMappingFixtures

  let(:druid) { collection_druid_fixture }

  let(:collection_json) do
    {
      druid:,
      release_option: 'depositor-selects',
      release_duration: '6 months',
      access: 'stanford',
      doi_option: 'yes',
      license_option: 'required',
      required_license: 'https://creativecommons.org/licenses/by/4.0/legalcode',
      default_license: nil,
      allow_custom_rights_statement: true,
      provided_custom_rights_statement: nil,
      custom_rights_statement_custom_instructions: 'These are the instructions',
      email_when_participants_changed: true,
      email_depositors_status_changed: false,
      review_enabled: true,
      creator: {
        id: 932,
        email: 'larry@stanford.edu',
        created_at: '2021-08-02T13:11:57.482Z',
        updated_at: '2024-02-24T02:30:22.262Z',
        name: 'Larry Fine',
        last_work_terms_agreement: nil,
        first_name: 'Larry'
      },
      depositors: [
        {
          id: 934,
          email: 'moe.howard@stanford.edu',
          created_at: '2021-08-02T13:11:57.491Z',
          updated_at: '2021-08-02T13:11:57.491Z',
          name: nil,
          last_work_terms_agreement: nil,
          first_name: nil
        }
      ],
      reviewed_by: [
        {
          id: 2721,
          email: 'shemp@stanford.edu',
          created_at: '2022-04-25T18:09:01.285Z',
          updated_at: '2022-05-05T21:34:04.318Z',
          name: 'Shemp Howard',
          last_work_terms_agreement: '2022-05-05T21:34:04.315Z',
          first_name: 'Shemp'
        }
      ],
      managed_by: [
        {
          id: 1523,
          email: 'therealcurly@stanford.edu',
          created_at: '2021-08-02T13:12:05.122Z',
          updated_at: '2021-09-07T17:46:19.326Z',
          name: 'Curly Howard',
          last_work_terms_agreement: nil,
          first_name: 'Jamie'
        }
      ]

    }.deep_stringify_keys
  end

  let(:cocina_object) do
    Cocina::Models.with_metadata(collection_fixture, lock_fixture, modified:)
  end

  let(:modified) { Time.zone.iso8601('2024-12-31T14:00:00') }

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
  end

  context 'when collection already exists' do
    let!(:collection) { create(:collection, druid:) }

    it 'does not create a new collection' do
      expect { described_class.call(collection_json:) }.not_to change(Collection, :count)
    end

    it 'returns collection' do
      expect(described_class.call(collection_json:)).to eq(collection)
    end
  end

  context 'when collection is roundtrippable' do
    it 'creates a new collection' do
      expect { described_class.call(collection_json:) }.to change(Collection, :count).by(1)
    end

    it 'populates collection attributes' do
      collection = described_class.call(collection_json:)

      expect(collection.druid).to eq(druid)
      expect(collection.title).to eq(collection_title_fixture)
      expect(collection.object_updated_at).to eq(modified)
      expect(collection.depositor_selects_release_option?).to be(true)
      expect(collection.six_months_release_duration?).to be(true)
      expect(collection.stanford_access?).to be(true)
      expect(collection.yes_doi_option?).to be(true)
      expect(collection.required_license_option?).to be(true)
      expect(collection.depositor_selects_custom_rights_statement_option?).to be(true)
      expect(collection.custom_rights_statement_custom_instructions).to eq('These are the instructions')
      expect(collection.email_when_participants_changed).to be(true)
      expect(collection.email_depositors_status_changed).to be(false)
      expect(collection.review_enabled).to be(true)
      expect(collection.user.email_address).to eq('larry@stanford.edu')
      expect(collection.depositors.first.email_address).to eq('moe.howard@stanford.edu')
      expect(collection.reviewers.first.email_address).to eq('shemp@stanford.edu')
      expect(collection.managers.first.email_address).to eq('therealcurly@stanford.edu')
    end
  end

  context 'when collection is not roundtrippable' do
    let(:cocina_object) { collection_with_metadata_fixture.new(type: Cocina::Models::ObjectType.curated_collection) }

    it 'raises an error and does not create a new collection' do
      expect do
        described_class.call(collection_json:)
      end.to raise_error(Importers::Error,
                         "Collection #{druid} cannot be roundtripped").and not_change(Collection, :count)
    end
  end
end
