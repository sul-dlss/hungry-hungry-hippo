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
        expect(described_class.register(cocina_object: cocina_object)).to eq(registered_cocina_object)

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
        expect { described_class.register(cocina_object: cocina_object) }.to raise_error(Sdr::Repository::Error)
      end
    end

    context 'when creating workflow fails' do
      before do
        allow(Sdr::Workflow).to receive(:create_unless_exists).and_raise(Sdr::Workflow::Error,
                                                                         'Failed to create workflow')
      end

      it 'raises' do
        expect { described_class.register(cocina_object: cocina_object) }.to raise_error(Sdr::Repository::Error)
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
        expect(described_class.find(druid: druid)).to eq(cocina_object)
        expect(Dor::Services::Client).to have_received(:object).with(druid)
      end
    end

    context 'when the object is not found' do
      before do
        allow(Dor::Services::Client).to receive(:object).and_raise(Dor::Services::Client::NotFoundResponse)
      end

      it 'raises' do
        expect { described_class.find(druid: druid) }.to raise_error(Sdr::Repository::NotFoundResponse)
      end
    end
  end

  describe '#status' do
    context 'when the object is found' do
      let(:object_client) { instance_double(Dor::Services::Client::Object, version: version_client) }
      let(:version_client) { instance_double(Dor::Services::Client::ObjectVersion, status:) }

      let(:status) { instance_double(Dor::Services::Client::ObjectVersion::VersionStatus) }

      before do
        allow(Dor::Services::Client).to receive(:object).and_return(object_client)
      end

      it 'returns the status' do
        expect(described_class.status(druid: druid)).to eq(status)
        expect(Dor::Services::Client).to have_received(:object).with(druid)
      end
    end

    context 'when the object is not found' do
      before do
        allow(Dor::Services::Client).to receive(:object).and_raise(Dor::Services::Client::NotFoundResponse)
      end

      it 'raises' do
        expect { described_class.status(druid: druid) }.to raise_error(Sdr::Repository::NotFoundResponse)
      end
    end
  end
end
