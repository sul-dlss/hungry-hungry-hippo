# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DepositGithubReleaseJob do
  include WorkMappingFixtures

  let(:github_release) { create(:github_release, status:, github_repository:, published_at:) }
  let(:github_repository) { create(:github_repository, druid: druid_fixture) }
  let(:published_at) { 2.hours.ago }

  let(:status) { :queued }
  let(:version_status) { build(:openable_version_status) }
  let(:downloader) { instance_double(Github::ReleaseDownloader, exist?: true) }

  let(:cocina_object) { dro_with_metadata_fixture }

  before do
    allow(Sdr::Repository).to receive(:status).and_return(version_status)
    allow(Honeybadger).to receive(:notify)
    allow(Github::ReleaseDownloader).to receive(:new).with(zip_url: github_release.zip_url).and_return(downloader)
    allow(downloader).to receive(:download_to) do |tempfile|
      tempfile.write('fake zip content')
    end
    allow(DepositWorkJob).to receive(:perform_now)
    allow(Sdr::Repository).to receive(:find).with(druid: druid_fixture).and_return(dro_with_metadata_fixture)
    allow(DoiAssignedService).to receive(:call).with(cocina_object:, work: github_repository).and_return(true)
  end

  context 'when the release is completed' do
    let(:status) { :completed }

    it 'does not process the release' do
      expect { described_class.perform_now(github_release:) }.not_to(change { github_release.reload.status })
    end
  end

  context 'when the release is started' do
    let(:status) { :started }

    it 'does not process the release' do
      expect { described_class.perform_now(github_release:) }.not_to(change { github_release.reload.status })
    end
  end

  context 'when an older incomplete release exists' do
    before do
      create(:github_release, github_repository:, published_at: 1.day.ago)
    end

    it 'does not process the release' do
      expect { described_class.perform_now(github_release:) }.not_to(change { github_release.reload.status })
    end
  end

  context 'when published less than an hour ago' do
    let(:published_at) { 30.minutes.ago }

    it 'does not process the release' do
      expect { described_class.perform_now(github_release:) }
        .to change { github_release.reload.status_details }.to('waiting about 1 hour after publishing')
      expect(github_release.queued?).to be true
      expect(Sdr::Repository).not_to have_received(:status)
    end
  end

  context 'when published less than an hour ago but skipping' do
    let(:published_at) { 30.minutes.ago }

    it 'processes the release' do
      expect { described_class.perform_now(github_release:, skip_publish_wait: true) }
        .to change { github_release.reload.status }.to('completed')
        .and change { github_repository.reload.deposit_state }.to('deposit_registering_or_updating')
    end
  end

  context 'when version is open but not closeable' do
    let(:version_status) { build(:version_status, open: true, closeable: false) }

    it 'does not process the release' do
      expect { described_class.perform_now(github_release:) }
        .to change { github_release.reload.status_details }.to('version is open but not closeable')
      expect(github_release.queued?).to be true
      expect(Honeybadger).to have_received(:notify).with('Version is open but not closeable')
    end
  end

  context 'when version is not open but not openable' do
    let(:version_status) { build(:version_status, open: false, openable: false) }

    it 'does not process the release' do
      expect { described_class.perform_now(github_release:) }
        .to change { github_release.reload.status_details }.to('version is not openable')
      expect(github_release.queued?).to be true
      expect(Honeybadger).to have_received(:notify).with('Version is not openable')
    end
  end

  context 'when zip file does not exist' do
    before do
      allow(downloader).to receive(:exist?).and_return(false)
    end

    it 'marks the release as completed' do
      expect { described_class.perform_now(github_release:) }
        .to change { github_release.reload.status }.to('completed')
        .and change(github_release, :status_details).to('version zip missing')
    end
  end

  context 'when all checks pass' do
    it 'processes the release' do
      expect { described_class.perform_now(github_release:) }
        .to change { github_release.reload.status }.to('completed')
        .and change { github_repository.reload.deposit_state }.to('deposit_registering_or_updating')
      expect(DepositWorkJob)
        .to have_received(:perform_now) do |work:, work_form:, deposit:, request_review:, current_user:|
          expect(work).to eq(github_repository)
          expect(work_form).to be_a(GithubRepositoryWorkForm)
          expect(deposit).to be true
          expect(request_review).to be false
          expect(current_user).to eq(github_repository.user)
          content = Content.find(work_form.content_id)
          expect(content.content_files.count).to eq(1)
          content_file = content.content_files.first
          expect(content_file.filepath).to eq('v1.0.zip')
          expect(content_file.file.attachment.blob.byte_size).to eq('fake zip content'.bytesize)
        end
    end
  end

  context 'when an error occurs during processing' do
    before do
      allow(DepositWorkJob).to receive(:perform_now).and_raise(StandardError, 'Something went wrong')
    end

    it 'marks the release as failed with error details and re-raises the error' do
      expect { described_class.perform_now(github_release:) }
        .to raise_error(StandardError, 'Something went wrong')
        .and change { github_release.reload.status }.to('failed')
        .and change(github_release, :status_details).to('error processing release: Something went wrong')
    end
  end
end
