# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositJob do
  before do
    allow(Sdr::Repository).to receive(:accession)
    allow(Turbo::StreamsChannel).to receive(:broadcast_refresh_to)
  end

  context 'when depositing a work' do
    let(:druid) { 'druid:bc123df4567' }
    let(:cocina_object) { instance_double(Cocina::Models::DROWithMetadata, externalIdentifier: druid) }
    let(:content) { create(:content) }

    before do
      allow(ToCocina::WorkMapper).to receive(:call).and_call_original
    end

    context 'when a new work' do
      let(:form) { WorkForm.new(title: object.title, content_id: content.id) }
      let(:object) { create(:work, :deposit_job_started) }
      let(:source_id) { "h3:object-#{object.id}" }

      before do
        allow(Sdr::Repository).to receive(:register).and_return(cocina_object)
      end

      it 'registers a new work' do
        described_class.perform_now(form:, object:, deposit: true)
        expect(ToCocina::WorkMapper).to have_received(:call).with(work_form: form, content:, source_id:)
        expect(Sdr::Repository).to have_received(:register)
          .with(cocina_object: an_instance_of(Cocina::Models::RequestDRO))
        expect(Sdr::Repository).to have_received(:accession).with(druid:)

        expect(object.reload.deposit_job_finished?).to be true
        expect(Turbo::StreamsChannel).to have_received(:broadcast_refresh_to).with('wait', object.id)
      end
    end

    context 'when an existing work' do
      let(:form) { WorkForm.new(title: object.title, druid:, content_id: content.id, lock: 'abc123') }
      let(:object) { create(:work, :deposit_job_started, druid:) }
      let(:source_id) { "h3:object-#{object.id}" }

      before do
        allow(Sdr::Repository).to receive_messages(open_if_needed: cocina_object, update: cocina_object)
      end

      it 'updates an existing work' do
        described_class.perform_now(form:, object:, deposit: false)
        expect(ToCocina::WorkMapper).to have_received(:call).with(work_form: form, content:, source_id:)
        expect(Sdr::Repository).to have_received(:open_if_needed)
          .with(cocina_object: an_instance_of(Cocina::Models::DROWithMetadata))
        expect(Sdr::Repository).to have_received(:update).with(cocina_object: cocina_object)
        expect(Sdr::Repository).not_to have_received(:accession)

        expect(object.reload.deposit_job_finished?).to be true
        expect(Turbo::StreamsChannel).to have_received(:broadcast_refresh_to).with('wait', object.id)
      end
    end
  end

  context 'when depositing a collection' do
    let(:druid) { 'druid:cc234dd5678' }
    let(:cocina_object) { instance_double(Cocina::Models::CollectionWithMetadata, externalIdentifier: druid) }

    before do
      allow(ToCocina::CollectionMapper).to receive(:call).and_call_original
    end

    context 'when a new collection' do
      let(:form) { CollectionForm.new(title: object.title) }
      let(:object) { create(:work, :deposit_job_started) }
      let(:source_id) { "h3:collection-#{object.id}" }

      before do
        allow(Sdr::Repository).to receive(:register).and_return(cocina_object)
      end

      it 'registers a new collection' do
        described_class.perform_now(form:, object:, deposit: true)
        expect(ToCocina::CollectionMapper).to have_received(:call).with(collection_form: form, source_id:)
        expect(Sdr::Repository).to have_received(:register)
          .with(cocina_object: an_instance_of(Cocina::Models::RequestCollection))
        expect(Sdr::Repository).to have_received(:accession).with(druid:)

        expect(object.reload.deposit_job_finished?).to be true
        expect(Turbo::StreamsChannel).to have_received(:broadcast_refresh_to).with('wait', object.id)
      end
    end

    context 'when an existing collection' do
      let(:form) { CollectionForm.new(title: object.title, druid:, lock: 'abc123') }
      let(:object) { create(:collection, :deposit_job_started, druid:) }
      let(:source_id) { "h3:collection-#{object.id}" }

      before do
        allow(Sdr::Repository).to receive_messages(open_if_needed: cocina_object, update: cocina_object)
      end

      it 'updates an existing collection' do
        described_class.perform_now(form:, object:, deposit: false)
        expect(ToCocina::CollectionMapper).to have_received(:call).with(collection_form: form, source_id:)
        expect(Sdr::Repository).to have_received(:open_if_needed)
          .with(cocina_object: an_instance_of(Cocina::Models::CollectionWithMetadata))
        expect(Sdr::Repository).to have_received(:update).with(cocina_object: cocina_object)
        expect(Sdr::Repository).not_to have_received(:accession)

        expect(object.reload.deposit_job_finished?).to be true
        expect(Turbo::StreamsChannel).to have_received(:broadcast_refresh_to).with('wait', object.id)
      end
    end
  end
end
