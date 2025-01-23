# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositCollectionJob do
  include CollectionMappingFixtures

  let(:druid) { collection_druid_fixture }
  let(:cocina_object) { collection_with_metadata_fixture }

  before do
    allow(ToCocina::Collection::Mapper).to receive(:call).and_call_original
    allow(Sdr::Repository).to receive(:accession)
  end

  context 'when a new collection' do
    let(:collection_form) { CollectionForm.new(title: collection.title, managers_attributes:, depositors_attributes:) }
    let(:collection) { create(:collection, :registering_or_updating) }
    let(:managers_attributes) { [{ sunetid: manager.sunetid }, { sunetid: 'stepking' }] }
    let(:depositors_attributes) { [{ sunetid: 'joehill' }] }
    let(:manager) { create(:user) }

    before do
      allow(Sdr::Repository).to receive(:register).and_return(cocina_object)
    end

    it 'registers a new collection' do
      described_class.perform_now(collection_form:, collection:, deposit: true)
      new_manager = User.find_by(email_address: 'stepking@stanford.edu')
      new_depositor = User.find_by(email_address: 'joehill@stanford.edu')
      expect(ToCocina::Collection::Mapper).to have_received(:call).with(collection_form:,
                                                                        source_id: "h3:collection-#{collection.id}")
      expect(Sdr::Repository).to have_received(:register)
        .with(cocina_object: an_instance_of(Cocina::Models::RequestCollection))
      expect(Sdr::Repository).to have_received(:accession).with(druid:)

      expect(collection.reload.accessioning?).to be true

      # These expectations verify that the new manager and depositor were created and associated with the collection.
      # As well as verifying that an existing managers name is not overwritten.
      expect(collection.managers).to include(manager, new_manager)
      expect(collection.depositors).to include(new_depositor)
      expect(manager.manages).to contain_exactly(collection)
      expect(new_manager.manages).to contain_exactly(collection)
      expect(new_depositor.depositor_for).to contain_exactly(collection)
      expect(new_manager.name).to eq('stepking')
      expect(new_depositor.name).to eq('joehill')
      expect(manager.name).not_to eq(manager.sunetid)
    end
  end

  context 'when an existing collection' do
    let(:collection_form) { CollectionForm.new(title: collection_title_fixture, druid:, lock: 'abc123') }
    let(:collection) { create(:collection, :registering_or_updating, druid:) }

    before do
      allow(Sdr::Repository).to receive_messages(open_if_needed: cocina_object, update: cocina_object)
    end

    it 'updates an existing collection' do
      described_class.perform_now(collection_form:, collection:, deposit: false)
      expect(ToCocina::Collection::Mapper).to have_received(:call).with(collection_form:,
                                                                        source_id: "h3:collection-#{collection.id}")
      expect(Sdr::Repository).to have_received(:open_if_needed)
        .with(cocina_object: an_instance_of(Cocina::Models::CollectionWithMetadata))
      expect(Sdr::Repository).to have_received(:update).with(cocina_object:)
      expect(Sdr::Repository).not_to have_received(:accession)

      expect(collection.reload.title).to eq(collection_title_fixture)
      expect(collection.deposit_not_in_progress?).to be true
    end
  end
end
