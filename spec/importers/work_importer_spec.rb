# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WorkImporter do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:work_hash) do
    {
      id: 4382,
      druid: druid_fixture,
      head_id: 4386,
      collection_id: 171,
      depositor_id: 1486,
      created_at: '2021-06-01T00:04:31.604Z',
      updated_at: '2023-09-20T21:14:40.429Z',
      assign_doi: false,
      doi: nil,
      owner_id: 1486,
      locked: false,
      owner: {
        id: 1486,
        email: user.email_address,
        created_at: '2021-08-02T13:12:04.444Z',
        updated_at: '2021-08-02T13:12:04.444Z',
        name: nil,
        last_work_terms_agreement: nil,
        first_name: nil
      },
      collection: {
        id: 171,
        release_option: 'immediate',
        release_duration: '6 months',
        access: 'depositor-selects',
        required_license: nil,
        default_license: 'none',
        email_when_participants_changed: false,
        created_at: '2014-08-21T23:22:46.396Z',
        updated_at: '2025-05-12T21:52:14.967Z',
        creator_id: 64,
        druid: collection_druid_fixture,
        email_depositors_status_changed: false,
        review_enabled: true,
        license_option: 'depositor-selects',
        head_id: 171,
        doi_option: 'yes',
        allow_custom_rights_statement: false,
        provided_custom_rights_statement: nil,
        custom_rights_statement_custom_instructions: nil
      },
      head: {
        id: 4386,
        version: 1,
        title: 'My Icon Collection for Green Cardamom Green Pepper Integration Test',
        work_type: 'image',
        created_edtf: nil,
        abstract: 'An abstract for Green Cardamom Green Pepper Integration Test logo',
        citation: 'Scully, D. (2023). My Icon Collection for Green Cardamom Green Pepper',
        access: 'world',
        embargo_dat: nil,
        license: 'CC0-1.0',
        created_at: '2023-09-28T19:17:35.582Z',
        updated_at: '2024-05-13T16:14:55.160Z',
        state: 'deposited',
        published_edtf: nil,
        subtype: [],
        work_id: 4382,
        version_description: nil,
        published_at: '2023-09-28T19:17:49.092Z',
        upload_type: 'browser',
        globus_endpoint: 'integration_test/work388/version2',
        globus_origin: nil,
        custom_rights: nil,
        user_version: 1
      }
    }.deep_stringify_keys
  end
  let(:cocina_object) { dro_with_structural_and_metadata_fixture }
  let(:user) { create(:user) }
  let!(:collection) { create(:collection, druid: collection_druid_fixture) }
  let(:object_client) { instance_double(Dor::Services::Client::Object, administrative_tags: tags_client) }
  let(:tags_client) { instance_double(Dor::Services::Client::AdministrativeTags, create: true) }

  before do
    allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    allow(Dor::Services::Client).to receive(:object).with(druid).and_return(object_client)
    allow(object_client).to receive(:administrative_tags).and_return(tags_client)
  end

  context 'when work can be roundtripped' do
    it 'imports a work' do
      expect { described_class.call(work_hash:, cocina_object:) }.to change(Work, :count).by(1)
      work = Work.find_by(druid: druid_fixture)
      expect(work.user).to eq(user)
      expect(work.collection).to eq(collection)
      expect(work.title).to eq(title_fixture)
      expect(work.version).to eq(2) # NOTE: this comes from cocina, not the work_version from H2
      expect(work.last_deposited_at.class).to be ActiveSupport::TimeWithZone
      expect(work.last_deposited_at).to eq('2023-09-28T19:17:49.092Z')

      expect(tags_client).to have_received(:create).with(tags: ['Project : H3'])
    end
  end

  context 'when the work already exists' do
    before do
      create(:work, druid: druid_fixture)
    end

    it 'imports a work' do
      expect { described_class.call(work_hash:, cocina_object:) }.not_to change(Work, :count)

      expect(tags_client).to have_received(:create).with(tags: ['Project : H3'])
    end
  end

  context 'when work cannot be roundtripped' do
    let(:cocina_object) do
      dro_with_structural_and_metadata_fixture.new(type: Cocina::Models::ObjectType.map)
    end

    it 'raises' do
      expect { described_class.call(work_hash:, cocina_object:) }.to raise_error(ImportError)

      expect(tags_client).not_to have_received(:create)
    end
  end
end
