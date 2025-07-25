# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositWorkJob do
  include WorkMappingFixtures

  let(:druid) { druid_fixture }
  let(:cocina_object) do
    dro_with_metadata_fixture.new(identification: {
                                    catalogLinks: [],
                                    doi: '10.80343/bc123df4567',
                                    sourceId: "h3:object-#{work.id}"
                                  })
  end
  # original_cocina_object is used for testing when the description has changed.
  let(:original_cocina_object) do
    cocina_object.new(description: cocina_object.description.new(
      title: DescriptionCocinaBuilder.title(title: 'Original title')
    ))
  end
  let(:content) { create(:content) }
  let(:collection) { create(:collection, druid: collection_druid_fixture) }
  let(:user) { create(:user) }
  let(:current_user) { create(:user) }

  before do
    allow(Contents::Analyzer).to receive(:call)
    allow(Cocina::WorkMapper).to receive(:call).and_call_original
    allow(Contents::Stager).to receive(:call)
    allow(Sdr::Repository).to receive(:accession)
    allow(Sdr::Repository).to receive(:register).and_return(cocina_object)
  end

  context 'when a new work' do
    let(:work) { create(:work, :registering_or_updating, collection:, user:) }
    let(:work_form) do
      new_work_form_fixture.tap do |form|
        form.content_id = content.id
        form.collection_druid = collection.druid
      end
    end

    it 'registers a new work' do
      expect do
        described_class.perform_now(work_form:, work:, deposit: true, request_review: false, current_user:)
      end.not_to change(user.reload, :agreed_to_terms_at)
      expect(Contents::Analyzer).to have_received(:call).with(content:)
      expect(Cocina::WorkMapper).to have_received(:call).with(work_form:, content:,
                                                              source_id: "h3:object-#{work.id}")
      expect(Contents::Stager).to have_received(:call).with(content:, druid:)
      expect(Sdr::Repository).to have_received(:register).with(
        cocina_object: an_instance_of(Cocina::Models::RequestDRO), assign_doi: true, user_name: current_user.sunetid
      ) do |args|
        event = args[:cocina_object].description.event.first
        expect(event.type).to eq 'deposit'
        expect(event.date.first.value).to eq Time.zone.today.iso8601
      end
      expect(Sdr::Repository).to have_received(:accession).with(druid:, new_user_version: true,
                                                                version_description: 'Initial version')

      expect(work.reload.accessioning?).to be true
      expect(work.pending_review?).to be false

      # Verifying that Current.user is being set for notifications
      expect(Current.user).to eq current_user
    end
  end

  context 'when a new work and not assigning a DOI' do
    let(:work) { create(:work, :registering_or_updating, collection:, user:) }
    let(:work_form) do
      new_work_form_fixture.tap do |form|
        form.content_id = content.id
        form.collection_druid = collection.druid
        form.doi_option = 'no'
      end
    end

    it 'registers a new work' do
      described_class.perform_now(work_form:, work:, deposit: true, request_review: false,
                                  current_user:)
      expect(Sdr::Repository).to have_received(:register)
        .with(cocina_object: an_instance_of(Cocina::Models::RequestDRO), assign_doi: false,
              user_name: current_user.sunetid)
    end
  end

  context 'when a new work with globus files' do
    let(:work) { create(:work, :registering_or_updating, collection:, user:, title: title_fixture) }
    let(:work_form) do
      new_work_form_fixture.tap do |form|
        form.content_id = content.id
        form.collection_druid = collection.druid
      end
    end
    let(:work_path) { "work-#{work.id}" }

    before do
      content.content_files << create(:content_file, :globus)
      allow(GlobusClient).to receive(:delete_access_rule)
        .with(user_id: user.email_address, path: work_path, notify_email: false)
        .and_raise(GlobusClient::AccessRuleNotFound, "Access rule not found in #{work_path}")
      allow(Sdr::Event).to receive(:create)
    end

    it 'registers a new work and updates the globus content' do
      described_class.perform_now(work_form:, work:, deposit: true, request_review: false, current_user:)

      expect(Sdr::Repository).to have_received(:register)
        .with(cocina_object: an_instance_of(Cocina::Models::RequestDRO), assign_doi: true,
              user_name: current_user.sunetid)
      expect(Contents::Analyzer).to have_received(:call).with(content:)
      expect(Sdr::Repository).to have_received(:accession).with(druid:, new_user_version: true,
                                                                version_description: 'Initial version')
      expect(Sdr::Event).to have_received(:create).with(druid:, type: 'h3_globus_staged', data: {})

      expect(GlobusClient).to have_received(:delete_access_rule)
    end
  end

  context 'when an existing work with changed cocina object and not depositing' do
    let(:work) { create(:work, :registering_or_updating, druid:) }
    let(:work_form) do
      work_form_fixture.tap do |form|
        form.content_id = content.id
        form.collection_druid = collection.druid
      end
    end

    let(:version_status) { build(:openable_version_status) }

    before do
      allow(Sdr::Repository).to receive_messages(open_if_needed: cocina_object, update: cocina_object)
      allow(RoundtripSupport).to receive(:changed?).and_call_original
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(original_cocina_object)
      allow(Sdr::Repository).to receive(:status).and_return(version_status)
      allow(Sdr::Repository).to receive(:find_latest_user_version).with(druid:).and_return(original_cocina_object)
    end

    it 'updates an existing work' do
      expect(work.title).not_to eq(title_fixture)

      described_class.perform_now(work_form:, work:, deposit: false, request_review: false,
                                  current_user:)
      expect(Contents::Analyzer).to have_received(:call).with(content:)
      expect(Cocina::WorkMapper).to have_received(:call).with(work_form:, content:,
                                                              source_id: "h3:object-#{work.id}")
      expect(Contents::Stager).to have_received(:call).with(content:, druid:)
      expect(Sdr::Repository).to have_received(:open_if_needed)
        .with(cocina_object: an_instance_of(Cocina::Models::DROWithMetadata),
              user_name: current_user.sunetid,
              version_description: whats_changing_fixture, status: version_status) do |args|
                event = args[:cocina_object].description.event.first
                expect(event.type).to eq 'deposit'
                expect(event.date.first.value).to eq '2024-06-10'
              end
      expect(Sdr::Repository).to have_received(:update)
        .with(cocina_object:, user_name: current_user.sunetid, description: nil)
      expect(Sdr::Repository).not_to have_received(:accession)
      expect(RoundtripSupport).to have_received(:changed?)

      expect(work.reload.title).to eq(title_fixture)

      expect(work.deposit_not_in_progress?).to be true
    end
  end

  context 'when an existing work with changed cocina object and depositing' do
    let(:work) { create(:work, :registering_or_updating, druid:) }
    let(:work_form) do
      work_form_fixture.tap do |form|
        form.content_id = content.id
        form.collection_druid = collection.druid
      end
    end
    let(:version_status) { build(:openable_version_status) }

    before do
      allow(Sdr::Repository).to receive_messages(open_if_needed: cocina_object, update: cocina_object)
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(original_cocina_object)
      allow(Sdr::Repository).to receive(:status).and_return(version_status)
      allow(Sdr::Repository).to receive(:find_latest_user_version).with(druid:).and_return(original_cocina_object)
    end

    it 'updates an existing work' do
      expect(work.title).not_to eq(title_fixture)

      described_class.perform_now(work_form:, work:, deposit: true, request_review: false,
                                  current_user:)
      expect(Sdr::Repository).to have_received(:open_if_needed)
        .with(cocina_object: an_instance_of(Cocina::Models::DROWithMetadata),
              user_name: current_user.sunetid,
              version_description: whats_changing_fixture, status: version_status) do |args|
                event = args[:cocina_object].description.event.first
                expect(event.type).to eq 'deposit'
                expect(event.date.first.value).to eq Time.zone.today.iso8601
              end
      expect(Sdr::Repository).to have_received(:update)
        .with(cocina_object:, user_name: current_user.sunetid, description: nil)
      expect(Sdr::Repository).to have_received(:accession).with(druid:, new_user_version: false,
                                                                version_description: 'I am changing the title.')
    end
  end

  context 'when an existing work with changed content and depositing' do
    let(:work) { create(:work, :registering_or_updating, druid:) }
    let(:work_form) do
      work_form_fixture.tap do |form|
        form.content_id = content.id
        form.collection_druid = collection.druid
      end
    end
    let(:version_status) { build(:openable_version_status) }
    # Note that the existing cocina object does not have any files, so having any content files is a change.
    let(:content) { create(:content, :with_content_files) }

    before do
      allow(Sdr::Repository).to receive_messages(open_if_needed: cocina_object, update: cocina_object)
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
      allow(Sdr::Repository).to receive(:status).and_return(version_status)
      allow(Sdr::Repository).to receive(:find_latest_user_version).with(druid:).and_return(cocina_object)
    end

    it 'updates an existing work' do
      expect(work.title).not_to eq(title_fixture)

      described_class.perform_now(work_form:, work:, deposit: true, request_review: false,
                                  current_user:)
      expect(Sdr::Repository).to have_received(:open_if_needed)
      expect(Sdr::Repository).to have_received(:update)
        .with(cocina_object:, user_name: current_user.sunetid, description: 'Files changed')
      expect(Sdr::Repository).to have_received(:accession).with(druid:, new_user_version: true,
                                                                version_description: 'I am changing the title.')
    end
  end

  context 'when an existing work with an unchanged, closed cocina object' do
    let(:work) { create(:work, :registering_or_updating, druid:) }
    let(:work_form) do
      work_form_fixture.tap do |form|
        form.content_id = content.id
        form.collection_druid = collection.druid
      end
    end
    let(:version_status) { build(:version_status) }

    before do
      allow(Sdr::Repository).to receive(:status).and_return(version_status)
      allow(Sdr::Repository).to receive_messages(open_if_needed: cocina_object, update: cocina_object)
      # Returning cocina_object will make this unchanged.
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
    end

    it 'updates an existing work' do
      expect(work.title).not_to eq(title_fixture)

      described_class.perform_now(work_form:, work:, deposit: true, request_review: false,
                                  current_user:)
      expect(Contents::Analyzer).to have_received(:call).with(content:)
      expect(Cocina::WorkMapper).to have_received(:call).with(work_form:, content:,
                                                              source_id: "h3:object-#{work.id}")
      expect(Contents::Stager).to have_received(:call).with(content:, druid:)
      expect(Sdr::Repository).not_to have_received(:open_if_needed)
      expect(Sdr::Repository).not_to have_received(:update)
      expect(Sdr::Repository).not_to have_received(:accession)

      expect(work.reload.title).to eq(title_fixture)

      expect(work.deposit_not_in_progress?).to be true
    end
  end

  context 'when an existing work with an unchanged, open cocina object' do
    let(:work) { create(:work, :registering_or_updating, druid:) }
    let(:work_form) do
      work_form_fixture.tap do |form|
        form.content_id = content.id
        form.collection_druid = collection.druid
      end
    end
    let(:version_status) { build(:draft_version_status) }

    before do
      allow(Sdr::Repository).to receive(:status).and_return(version_status)
      allow(Sdr::Repository).to receive_messages(open_if_needed: cocina_object, update: cocina_object)
      # Returning cocina_object will make this unchanged.
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
      allow(Sdr::Repository).to receive(:find_latest_user_version).with(druid:).and_return(cocina_object)
    end

    it 'updates an existing work' do
      expect(work.title).not_to eq(title_fixture)

      described_class.perform_now(work_form:, work:, deposit: true, request_review: false, current_user:)
      expect(Contents::Analyzer).to have_received(:call).with(content:)
      expect(Cocina::WorkMapper).to have_received(:call).with(work_form:, content:,
                                                              source_id: "h3:object-#{work.id}")
      expect(Contents::Stager).to have_received(:call).with(content:, druid:)
      expect(Sdr::Repository).not_to have_received(:open_if_needed)
      expect(Sdr::Repository).not_to have_received(:update)
      expect(Sdr::Repository).to have_received(:accession).with(druid:, new_user_version: false,
                                                                version_description: 'I am changing the title.')

      expect(work.reload.title).to eq(title_fixture)

      expect(work.deposit_not_in_progress?).to be false
    end
  end

  context 'when user has not previously agreed to terms of use' do
    let(:user) { create(:user, agreed_to_terms_at: nil) }

    let(:work_form) { WorkForm.new(title: work.title, content_id: content.id, collection_druid: collection.druid) }
    let(:work) { create(:work, :registering_or_updating, collection:, user:) }

    before do
      allow(Sdr::Repository).to receive(:register).and_return(cocina_object)
    end

    it 'update the user' do
      expect do
        described_class.perform_now(work_form:, work:, deposit: true, request_review: false, current_user:)
      end.to change(user.reload, :agreed_to_terms_at)
    end
  end

  context 'when review requested' do
    let(:work_form) { WorkForm.new(title: work.title, content_id: content.id, collection_druid: collection.druid) }
    let(:work) { create(:work, :registering_or_updating, collection:) }

    it 'registers a new work' do
      described_class.perform_now(work_form:, work:, deposit: true, request_review: true, current_user:)

      expect(work.reload.pending_review?).to be true
      expect(Sdr::Repository).not_to have_received(:accession)
    end
  end

  context 'when review rejected but a manager or reviewer deposits' do
    let(:druid) { druid_fixture }
    let(:cocina_object) { dro_with_metadata_fixture }
    let(:work_form) { WorkForm.new(druid:, content_id: content.id) }
    let(:work) { create(:work, :rejected_review, druid:, collection:) }
    let(:version_status) { build(:draft_version_status) }
    let(:collection) { create(:collection, druid: collection_druid_fixture, reviewers: [current_user]) }

    before do
      allow(Sdr::Repository).to receive(:status).and_return(version_status)
      allow(Cocina::WorkMapper).to receive(:call).and_return(cocina_object)
      allow(RoundtripSupport).to receive(:changed?).and_return(false)
      allow(Sdr::Repository).to receive(:find).with(druid:).and_return(cocina_object)
      allow(Sdr::Repository).to receive(:find_latest_user_version).with(druid:).and_return(cocina_object)
    end

    it 'approves the work and deposits' do
      expect(work.rejected_review?).to be true
      described_class.perform_now(work_form:, work:, deposit: true, request_review: false, current_user:)

      expect(work.review_not_in_progress?).to be true
      expect(Sdr::Repository).to have_received(:accession)
    end
  end
end
