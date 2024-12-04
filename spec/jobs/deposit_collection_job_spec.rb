# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositCollectionJob do
  let(:druid) { 'druid:cc234dd5678' }
  let(:cocina_object) { instance_double(Cocina::Models::CollectionWithMetadata, externalIdentifier: druid) }

  before do
    allow(ToCocina::Collection::Mapper).to receive(:call).and_call_original
    allow(Sdr::Repository).to receive(:accession)
  end

  context 'when a new collection' do
    let(:collection_form) { CollectionForm.new(title: collection.title) }
    let(:collection) { create(:collection, :deposit_job_started) }

    before do
      allow(Sdr::Repository).to receive(:register).and_return(cocina_object)
    end

    it 'registers a new work' do
      described_class.perform_now(collection_form:, collection:, deposit: true)
      expect(ToCocina::Collection::Mapper).to have_received(:call).with(collection_form: collection_form,
                                                                        source_id: "h3:collection-#{collection.id}")
      expect(Sdr::Repository).to have_received(:register)
        .with(cocina_object: an_instance_of(Cocina::Models::RequestCollection))
      expect(Sdr::Repository).to have_received(:accession).with(druid:)

      expect(collection.reload.deposit_job_finished?).to be true
    end
  end

  context 'when an existing collection' do
    let(:collection_form) { CollectionForm.new(title: collection.title, druid:, lock: 'abc123') }
    let(:collection) { create(:collection, :deposit_job_started, druid:) }

    before do
      allow(Sdr::Repository).to receive_messages(open_if_needed: cocina_object, update: cocina_object)
    end

    it 'updates an existing collection' do
      described_class.perform_now(collection_form: collection_form, collection: collection, deposit: false)
      expect(ToCocina::Collection::Mapper).to have_received(:call).with(collection_form: collection_form,
                                                                        source_id: "h3:collection-#{collection.id}")
      expect(Sdr::Repository).to have_received(:open_if_needed)
        .with(cocina_object: an_instance_of(Cocina::Models::CollectionWithMetadata))
      expect(Sdr::Repository).to have_received(:update).with(cocina_object: cocina_object)
      expect(Sdr::Repository).not_to have_received(:accession)

      expect(collection.reload.deposit_job_finished?).to be true
    end
  end
end
