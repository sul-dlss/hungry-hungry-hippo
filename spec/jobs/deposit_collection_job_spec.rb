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
    let(:managers_attributes) { [{ sunetid: manager.sunetid }, { sunetid: 'stepking', name: 'Stephen King' }] }
    let(:depositors_attributes) { [{ sunetid: 'joehill', name: 'Joe Hill' }] }
    let(:manager) { create(:user) }

    before do
      allow(Sdr::Repository).to receive(:register).and_return(cocina_object)
    end

    it 'registers a new collection' do
      described_class.perform_now(collection_form:, collection:)
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
      expect(new_manager.name).to eq('Stephen King')
      expect(new_depositor.name).to eq('Joe Hill')
      expect(manager.name).not_to eq(manager.sunetid)
      expect(collection.email_when_participants_changed).to be true
      expect(collection.email_depositors_status_changed).to be true

      expect(collection.custom_rights_statement_option).to eq('no') # default
    end

    context 'when a custom rights statement is provided' do
      let(:collection_form) do
        CollectionForm.new(title: collection.title,
                           managers_attributes: [],
                           depositors_attributes: [],
                           custom_rights_statement_option: 'provided',
                           provided_custom_rights_statement: 'This is a custom rights statement')
      end

      it 'registers a new collection with a custom rights statement' do
        described_class.perform_now(collection_form:, collection:)
        expect(collection.reload.custom_rights_statement_option).to eq('provided')
        expect(collection.provided_custom_rights_statement).to eq('This is a custom rights statement')
      end
    end

    context 'when the depositor can enter the custom rights statement' do
      let(:collection_form) do
        CollectionForm.new(title: collection.title,
                           managers_attributes: [],
                           depositors_attributes: [],
                           custom_rights_statement_option: 'depositor_selects',
                           custom_rights_statement_instructions: 'Please enter a custom rights statement')
      end

      it 'registers a new collection with instructions for entering the rights statement' do
        described_class.perform_now(collection_form:, collection:)
        expect(collection.reload.custom_rights_statement_option).to eq('depositor_selects')
        expect(collection.reload.custom_rights_statement_instructions).to eq('Please enter a custom rights statement')
      end
    end
  end

  context 'when an existing collection with changed cocina object' do
    let(:collection_form) { CollectionForm.new(title: collection_title_fixture, druid:, lock: 'abc123') }
    let(:collection) { create(:collection, :registering_or_updating, druid:) }

    before do
      allow(Sdr::Repository).to receive_messages(open_if_needed: cocina_object, update: cocina_object)
      allow(RoundtripSupport).to receive(:changed?).and_return(true)
    end

    it 'updates an existing collection' do
      described_class.perform_now(collection_form:, collection:)
      expect(ToCocina::Collection::Mapper).to have_received(:call).with(collection_form:,
                                                                        source_id: "h3:collection-#{collection.id}")
      expect(Sdr::Repository).to have_received(:open_if_needed)
        .with(cocina_object: an_instance_of(Cocina::Models::CollectionWithMetadata))
      expect(Sdr::Repository).to have_received(:update).with(cocina_object:)
      expect(Sdr::Repository).to have_received(:accession)
      expect(RoundtripSupport).to have_received(:changed?)

      expect(collection.reload.title).to eq(collection_title_fixture)
      expect(collection.deposit_not_in_progress?).to be false
    end
  end

  context 'when an existing collection with unchanged cocina object' do
    let(:collection_form) { CollectionForm.new(title: collection_title_fixture, druid:, lock: 'abc123') }
    let(:collection) { create(:collection, :registering_or_updating, druid:) }

    before do
      allow(Sdr::Repository).to receive_messages(open_if_needed: cocina_object, update: cocina_object)
      allow(RoundtripSupport).to receive(:changed?).and_return(false)
    end

    it 'updates an existing collection' do
      described_class.perform_now(collection_form:, collection:)
      expect(ToCocina::Collection::Mapper).to have_received(:call).with(collection_form:,
                                                                        source_id: "h3:collection-#{collection.id}")
      expect(Sdr::Repository).not_to have_received(:open_if_needed)
      expect(Sdr::Repository).not_to have_received(:update)
      expect(Sdr::Repository).not_to have_received(:accession)
      expect(RoundtripSupport).to have_received(:changed?)

      expect(collection.deposit_not_in_progress?).to be true
    end
  end

  context 'when adding participants to an existing collection with an unchanged cocina object' do
    let(:collection_form) do
      CollectionForm.new(title: collection_title_fixture,
                         druid:,
                         lock: 'abc123',
                         managers_attributes:)
    end
    let(:collection) { create(:collection, :registering_or_updating, druid:) }
    let(:managers_attributes) { [{ sunetid: manager.sunetid }] }
    let(:manager) { create(:user) }

    before do
      allow(Sdr::Repository).to receive_messages(open_if_needed: cocina_object, update: cocina_object)
      allow(RoundtripSupport).to receive(:changed?).and_return(false)
      allow(Notifier).to receive(:publish)
    end

    it 'publishes a MANGER_ADDED notification' do
      described_class.perform_now(collection_form:, collection:)
      expect(collection.managers).to include(manager)
      expect(Notifier).to have_received(:publish).with(Notifier::MANAGER_ADDED, collection:, user: manager)
    end
  end

  context 'when removing participants to an existing collection with an unchanged cocina object' do
    let(:collection_form) do
      CollectionForm.new(title: collection_title_fixture,
                         druid:,
                         lock: 'abc123',
                         managers_attributes:)
    end
    let(:collection) do
      create(:collection, :registering_or_updating, druid:, managers: [first_manager, second_manager])
    end
    let(:managers_attributes) { [{ sunetid: first_manager.sunetid }] }
    let(:first_manager) { create(:user) }
    let(:second_manager) { create(:user) }

    before do
      allow(Sdr::Repository).to receive_messages(open_if_needed: cocina_object, update: cocina_object)
      allow(RoundtripSupport).to receive(:changed?).and_return(false)
      allow(Notifier).to receive(:publish)
    end

    it 'only publishes a MANGER_REMOVED notification' do
      described_class.perform_now(collection_form:, collection:)
      expect(collection.managers).to include(first_manager)
      expect(collection.managers).not_to include(second_manager)
      expect(Notifier).to have_received(:publish).with(Notifier::MANAGER_REMOVED, collection:, user: second_manager)
      expect(Notifier).not_to have_received(:publish).with(Notifier::MANAGER_ADDED)
    end
  end
end
