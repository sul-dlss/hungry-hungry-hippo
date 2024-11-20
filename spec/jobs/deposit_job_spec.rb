# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositJob do
  include MappingFixtures

  let(:druid) { druid_fixture }
  let(:cocina_object) { dro_with_metadata_fixture }

  before do
    allow(ToCocina::Mapper).to receive(:call).and_call_original
    allow(Sdr::Repository).to receive(:accession)
    allow(Turbo::StreamsChannel).to receive(:broadcast_refresh_to)
  end

  context 'when a new work' do
    let(:content) { new_content_fixture }
    let(:work_form) { new_work_form_fixture.tap { |form| form.content_id = content.id } }
    let(:work) { create(:work, :deposit_job_started) }

    before do
      allow(Sdr::Repository).to receive(:register).and_return(cocina_object)
    end

    it 'registers a new work' do
      described_class.perform_now(work_form:, work:, deposit: true)
      expect(ToCocina::Mapper).to have_received(:call).with(work_form:, content:, source_id: "h3:object-#{work.id}")
      expect(Sdr::Repository).to have_received(:register)
        .with(cocina_object: an_instance_of(Cocina::Models::RequestDRO))
      expect(Sdr::Repository).to have_received(:accession).with(druid:)

      expect(work.reload.deposit_job_finished?).to be true
      expect(work.title).to eq(work_form.title)
      expect(work.druid).to eq(druid_fixture)
      # TODO: Test collection
      expect(Turbo::StreamsChannel).to have_received(:broadcast_refresh_to).with('wait', work.id)
    end
  end

  context 'when an existing work' do
    let(:content) { content_fixture }
    let(:work_form) { work_form_fixture.tap { |form| form.content_id = content.id } }
    let(:work) { create(:work, :deposit_job_started, druid:) }

    before do
      allow(Sdr::Repository).to receive_messages(open_if_needed: cocina_object, update: cocina_object)
    end

    it 'updates an existing work' do
      described_class.perform_now(work_form: work_form, work: work, deposit: false)
      expect(ToCocina::Mapper).to have_received(:call).with(work_form:, content:, source_id: "h3:object-#{work.id}")
      expect(Sdr::Repository).to have_received(:open_if_needed)
        .with(cocina_object: an_instance_of(Cocina::Models::DROWithMetadata))
      expect(Sdr::Repository).to have_received(:update).with(cocina_object: cocina_object)
      expect(Sdr::Repository).not_to have_received(:accession)

      expect(work.reload.deposit_job_finished?).to be true
      expect(work.title).to eq(work_form.title)
      # TODO: Test collection
      expect(Turbo::StreamsChannel).to have_received(:broadcast_refresh_to).with('wait', work.id)
    end
  end
end
