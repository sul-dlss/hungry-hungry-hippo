# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositWorkJob do
  let(:druid) { 'druid:bc123df4567' }
  let(:cocina_object) { instance_double(Cocina::Models::DROWithMetadata, externalIdentifier: druid) }
  let(:content) { create(:content) }
  let(:collection) { create(:collection) }

  before do
    allow(Contents::Analyzer).to receive(:call)
    allow(ToCocina::Work::Mapper).to receive(:call).and_call_original
    allow(Contents::Stager).to receive(:call)
    allow(Sdr::Repository).to receive(:accession)
    allow(Turbo::StreamsChannel).to receive(:broadcast_refresh_to)
  end

  context 'when a new work' do
    let(:work_form) { WorkForm.new(title: work.title, content_id: content.id, collection_druid: collection.druid) }
    let(:work) { create(:work, :deposit_job_started, collection:) }

    before do
      allow(Sdr::Repository).to receive(:register).and_return(cocina_object)
    end

    it 'registers a new work' do
      described_class.perform_now(work_form:, work:, deposit: true)
      expect(Contents::Analyzer).to have_received(:call).with(content: content)
      expect(ToCocina::Work::Mapper).to have_received(:call).with(work_form:, content:,
                                                                  source_id: "h3:object-#{work.id}")
      expect(Contents::Stager).to have_received(:call).with(content: content, druid: druid)
      expect(Sdr::Repository).to have_received(:register)
        .with(cocina_object: an_instance_of(Cocina::Models::RequestDRO))
      expect(Sdr::Repository).to have_received(:accession).with(druid:)

      expect(work.reload.deposit_job_finished?).to be true
      expect(Turbo::StreamsChannel).to have_received(:broadcast_refresh_to).with('wait', work.id)
    end
  end

  context 'when an existing work' do
    let(:work_form) do
      WorkForm.new(title: work.title, druid:, content_id: content.id, lock: 'abc123',
                   collection_druid: collection.druid)
    end
    let(:work) { create(:work, :deposit_job_started, druid:) }

    before do
      allow(Sdr::Repository).to receive_messages(open_if_needed: cocina_object, update: cocina_object)
    end

    it 'updates an existing work' do
      described_class.perform_now(work_form: work_form, work: work, deposit: false)
      expect(Contents::Analyzer).to have_received(:call).with(content: content)
      expect(ToCocina::Work::Mapper).to have_received(:call).with(work_form:, content:,
                                                                  source_id: "h3:object-#{work.id}")
      expect(Contents::Stager).to have_received(:call).with(content: content, druid: druid)
      expect(Sdr::Repository).to have_received(:open_if_needed)
        .with(cocina_object: an_instance_of(Cocina::Models::DROWithMetadata))
      expect(Sdr::Repository).to have_received(:update).with(cocina_object: cocina_object)
      expect(Sdr::Repository).not_to have_received(:accession)

      expect(work.reload.deposit_job_finished?).to be true
      expect(Turbo::StreamsChannel).to have_received(:broadcast_refresh_to).with('wait', work.id)
    end
  end
end
