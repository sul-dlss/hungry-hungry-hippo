# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositJob do
  context 'when a new work' do
    let(:work_form) { WorkForm.new(title: work.title) }
    let(:work) { create(:work, :deposit_job_started) }

    let(:cocina_object) { instance_double(Cocina::Models::DRO, externalIdentifier: 'druid:bc123df4567') }

    before do
      allow(ToCocina::Mapper).to receive(:call).and_call_original
      allow(Sdr::Repository).to receive(:register).and_return(cocina_object)
      allow(Sdr::Repository).to receive(:accession)
      allow(Turbo::StreamsChannel).to receive(:broadcast_refresh_to)
    end

    it 'registers a new work' do
      described_class.perform_now(work_form:, work:, deposit: true)
      expect(ToCocina::Mapper).to have_received(:call).with(work_form: work_form, source_id: "h3:object-#{work.id}")
      expect(Sdr::Repository).to have_received(:register)
        .with(cocina_object: an_instance_of(Cocina::Models::RequestDRO))
      expect(Sdr::Repository).to have_received(:accession).with(druid: 'druid:bc123df4567')

      expect(work.reload.deposit_job_finished?).to be true
      expect(Turbo::StreamsChannel).to have_received(:broadcast_refresh_to).with('wait', work.id)
    end
  end
end
