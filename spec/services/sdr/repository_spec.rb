# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sdr::Repository do
  let(:druid) { 'druid:bc123df4567' }

  describe '#register' do
    let(:cocina_object) { instance_double(Cocina::Models::RequestDRO) }
    let(:registered_cocina_object) { instance_double(Cocina::Models::DRO, externalIdentifier: druid) }

    let(:objects_client) { instance_double(Dor::Services::Client::Objects, register: registered_cocina_object) }

    before do
      allow(Dor::Services::Client).to receive(:objects).and_return(objects_client)
    end

    context 'when successful' do
      before do
        allow(Sdr::Workflow).to receive(:create_unless_exists)
      end

      it 'registers with SDR and creates registrationWF' do
        expect(described_class.register(cocina_object:)).to eq(registered_cocina_object)

        expect(objects_client).to have_received(:register).with(params: cocina_object, assign_doi: false)
        expect(Sdr::Workflow).to have_received(:create_unless_exists).with(druid, 'registrationWF', version: 1)
      end
    end

    context 'when registration fails' do
      let(:objects_client) { instance_double(Dor::Services::Client::Objects) }

      before do
        allow(objects_client).to receive(:register).and_raise(Dor::Services::Client::Error, 'Failed to register')
      end

      it 'raises' do
        expect { described_class.register(cocina_object:) }.to raise_error(Sdr::Repository::Error)
      end
    end

    context 'when creating workflow fails' do
      before do
        allow(Sdr::Workflow).to receive(:create_unless_exists).and_raise(Sdr::Workflow::Error,
                                                                         'Failed to create workflow')
      end

      it 'raises' do
        expect { described_class.register(cocina_object:) }.to raise_error(Sdr::Repository::Error)
      end
    end
  end

  describe '#accession' do
    let(:object_client) { instance_double(Dor::Services::Client::Object, version: version_client) }
    let(:version_client) { instance_double(Dor::Services::Client::ObjectVersion, close: true) }

    before do
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    end

    context 'when successful' do
      it 'closes the version' do
        described_class.accession(druid:)

        expect(Dor::Services::Client).to have_received(:object).with(druid)
        expect(version_client).to have_received(:close).with(user_versions: 'none')
      end
    end

    context 'when closing version fails' do
      before do
        allow(version_client).to receive(:close).and_raise(Dor::Services::Client::Error, 'Failed to close version')
      end

      it 'raises' do
        expect { described_class.accession(druid:) }.to raise_error(Sdr::Repository::Error)
      end
    end
  end

  describe '#find' do
    context 'when the object is found' do
      let(:object_client) { instance_double(Dor::Services::Client::Object, find: cocina_object) }

      let(:cocina_object) { instance_double(Cocina::Models::DRO) }

      before do
        allow(Dor::Services::Client).to receive(:object).and_return(object_client)
      end

      it 'returns the object' do
        expect(described_class.find(druid:)).to eq(cocina_object)
        expect(Dor::Services::Client).to have_received(:object).with(druid)
      end
    end

    context 'when the object is not found' do
      before do
        allow(Dor::Services::Client).to receive(:object).and_raise(Dor::Services::Client::NotFoundResponse)
      end

      it 'raises' do
        expect { described_class.find(druid:) }.to raise_error(Sdr::Repository::NotFoundResponse)
      end
    end
  end

  describe '#status' do
    context 'when the object is found' do
      let(:object_client) { instance_double(Dor::Services::Client::Object, version: version_client) }
      let(:version_client) { instance_double(Dor::Services::Client::ObjectVersion, status: version_status) }

      let(:version_status) { instance_double(Dor::Services::Client::ObjectVersion::VersionStatus) }

      before do
        allow(Dor::Services::Client).to receive(:object).and_return(object_client)
      end

      it 'returns the status' do
        expect(described_class.status(druid:)).to be_a VersionStatus
        expect(Dor::Services::Client).to have_received(:object).with(druid)
      end
    end

    context 'when the object is not found' do
      before do
        allow(Dor::Services::Client).to receive(:object).and_raise(Dor::Services::Client::NotFoundResponse)
      end

      it 'raises' do
        expect { described_class.status(druid:) }.to raise_error(Sdr::Repository::NotFoundResponse)
      end
    end
  end

  describe '#open_if_needed' do
    subject(:open_cocina_object) { described_class.open_if_needed(cocina_object:, version_description:) }

    let(:object_client) { instance_double(Dor::Services::Client::Object, version: version_client) }
    let(:version_client) { instance_double(Dor::Services::Client::ObjectVersion, status: version_status) }

    let(:version_status) do
      instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, open?: open, openable?: openable)
    end
    let(:open) { false }
    let(:openable) { true }

    let(:cocina_object) { build(:dro_with_metadata, id: druid) }
    let(:version_description) { 'Changed something' }

    before do
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    end

    context 'when already open' do
      let(:open) { true }

      it 'returns' do
        expect(open_cocina_object).to eq cocina_object
      end
    end

    context 'when not openable' do
      let(:openable) { false }

      it 'raises' do
        expect { open_cocina_object }.to raise_error(Sdr::Repository::Error)
      end
    end

    context 'when openable' do
      let(:open_cocina_object_from_dsa) { instance_double(Cocina::Models::DROWithMetadata, version: 2, lock: 'bcd234') }

      before do
        allow(version_client).to receive(:open).and_return(open_cocina_object_from_dsa)
      end

      it 'opens a new version' do
        expect(open_cocina_object.version).to eq(2)
        expect(open_cocina_object.lock).to eq('bcd234')
        expect(version_client).to have_received(:open).with(description: version_description)
      end
    end

    context 'when opening fails' do
      before do
        allow(version_client).to receive(:open).and_raise(Dor::Services::Client::Error, 'Failed to open')
      end

      it 'raises' do
        expect { open_cocina_object }.to raise_error(Sdr::Repository::Error)
      end
    end
  end

  describe '#update' do
    let(:cocina_object) { instance_double(Cocina::Models::DRO, externalIdentifier: druid) }

    let(:updated_cocina_object) { instance_double(Cocina::Models::DRO) }

    let(:object_client) { instance_double(Dor::Services::Client::Object, update: updated_cocina_object) }

    before do
      allow(Dor::Services::Client).to receive(:object).with(druid).and_return(object_client)
    end

    context 'when successful' do
      it 'updates with SDR' do
        expect(described_class.update(cocina_object:)).to eq(updated_cocina_object)

        expect(object_client).to have_received(:update).with(params: cocina_object)
      end
    end

    context 'when update fails' do
      let(:objects_client) { instance_double(Dor::Services::Client::Objects) }

      before do
        allow(object_client).to receive(:update).and_raise(Dor::Services::Client::Error, 'Failed to update')
      end

      it 'raises' do
        expect { described_class.update(cocina_object:) }.to raise_error(Sdr::Repository::Error)
      end
    end
  end

  describe '#discard_draft' do
    let(:object_client) { instance_double(Dor::Services::Client::Object, version: version_client, destroy: true) }
    let(:version_client) do
      instance_double(Dor::Services::Client::ObjectVersion, status: version_status, discard: true)
    end

    let(:version_status) do
      instance_double(Dor::Services::Client::ObjectVersion::VersionStatus, version:, discardable?: discardable,
                                                                           open?: true)
    end

    let(:version) { 2 }
    let(:discardable) { true }

    before do
      allow(Dor::Services::Client).to receive(:object).and_return(object_client)
    end

    context 'when the draft is not discardable' do
      let(:discardable) { false }

      it 'raises' do
        expect do
          described_class.discard_draft(druid:)
        end.to raise_error(Sdr::Repository::Error, 'Draft cannot be discarded')
      end
    end

    context 'when the version is 1' do
      let(:version) { 1 }

      it 'destroys the object' do
        described_class.discard_draft(druid:)

        expect(object_client).to have_received(:destroy)
      end
    end

    context 'when the version is not 1' do
      it 'discards the version' do
        described_class.discard_draft(druid:)

        expect(version_client).to have_received(:discard)
      end
    end
  end
end
