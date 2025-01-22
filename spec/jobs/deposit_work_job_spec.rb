# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositWorkJob do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:cocina_object) { dro_with_metadata_fixture }
  let(:content) { create(:content) }
  let(:collection) { create(:collection, druid: collection_druid_fixture) }
  let(:user) { create(:user) }

  before do
    allow(Contents::Analyzer).to receive(:call)
    allow(ToCocina::Work::Mapper).to receive(:call).and_call_original
    allow(Contents::Stager).to receive(:call)
    allow(Sdr::Repository).to receive(:accession)
    allow(Sdr::Repository).to receive(:register).and_return(cocina_object)
  end

  context 'when a new work' do
    let(:work_form) { WorkForm.new(title: work.title, content_id: content.id, collection_druid: collection.druid) }
    let(:work) { create(:work, :deposit_job_started, collection:, user:) }

    it 'registers a new work' do
      expect do
        described_class.perform_now(work_form:, work:, deposit: true, request_review: false)
      end.not_to change(user.reload, :agreed_to_terms_at)
      expect(Contents::Analyzer).to have_received(:call).with(content:)
      expect(ToCocina::Work::Mapper).to have_received(:call).with(work_form:, content:,
                                                                  source_id: "h3:object-#{work.id}")
      expect(Contents::Stager).to have_received(:call).with(content:, druid:)
      expect(Sdr::Repository).to have_received(:register)
        .with(cocina_object: an_instance_of(Cocina::Models::RequestDRO), assign_doi: true)
      expect(Sdr::Repository).to have_received(:accession).with(druid:)

      expect(work.reload.deposit_job_finished?).to be true
      expect(work.pending_review?).to be false
    end
  end

  context 'when a new work and not assigning a DOI' do
    let(:work_form) do
      WorkForm.new(title: work.title, content_id: content.id, collection_druid: collection.druid, doi_option: 'no')
    end
    let(:work) { create(:work, :deposit_job_started, collection:) }

    it 'registers a new work' do
      described_class.perform_now(work_form:, work:, deposit: true, request_review: false)
      expect(Sdr::Repository).to have_received(:register)
        .with(cocina_object: an_instance_of(Cocina::Models::RequestDRO), assign_doi: false)
    end
  end

  context 'when an existing work' do
    let(:work_form) do
      WorkForm.new(title: title_fixture, druid:, content_id: content.id, lock: 'abc123',
                   collection_druid: collection.druid)
    end
    let(:work) { create(:work, :deposit_job_started, druid:) }

    before do
      allow(Sdr::Repository).to receive_messages(open_if_needed: cocina_object, update: cocina_object)
    end

    it 'updates an existing work' do
      expect(work.title).not_to eq(title_fixture)

      described_class.perform_now(work_form:, work:, deposit: false, request_review: false)
      expect(Contents::Analyzer).to have_received(:call).with(content:)
      expect(ToCocina::Work::Mapper).to have_received(:call).with(work_form:, content:,
                                                                  source_id: "h3:object-#{work.id}")
      expect(Contents::Stager).to have_received(:call).with(content:, druid:)
      expect(Sdr::Repository).to have_received(:open_if_needed)
        .with(cocina_object: an_instance_of(Cocina::Models::DROWithMetadata))
      expect(Sdr::Repository).to have_received(:update).with(cocina_object:)
      expect(Sdr::Repository).not_to have_received(:accession)

      expect(work.reload.title).to eq(title_fixture)

      expect(work.deposit_job_finished?).to be true
    end
  end

  context 'when user has not previously agreed to terms of use' do
    let(:user) { create(:user, agreed_to_terms_at: nil) }

    let(:work_form) { WorkForm.new(title: work.title, content_id: content.id, collection_druid: collection.druid) }
    let(:work) { create(:work, :deposit_job_started, collection:, user:) }

    before do
      allow(Sdr::Repository).to receive(:register).and_return(cocina_object)
    end

    it 'update the user' do
      expect do
        described_class.perform_now(work_form:, work:, deposit: true, request_review: false)
      end.to change(user.reload, :agreed_to_terms_at)
    end
  end

  context 'when review requested' do
    let(:work_form) { WorkForm.new(title: work.title, content_id: content.id, collection_druid: collection.druid) }
    let(:work) { create(:work, :deposit_job_started, collection:) }

    it 'registers a new work' do
      described_class.perform_now(work_form:, work:, deposit: true, request_review: true)

      expect(work.reload.pending_review?).to be true
    end
  end
end
