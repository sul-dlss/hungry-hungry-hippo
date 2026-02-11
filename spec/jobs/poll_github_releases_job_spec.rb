# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PollGithubReleasesJob do
  let!(:github_repository) do
    create(:github_repository, github_deposit_enabled: enabled, created_at: 3.days.ago).tap do |repo|
      create(:github_release, release_tag: 'v1.1',
                              release_name: 'Second release', release_id: 2,
                              github_repository: repo,
                              zip_url: 'https://api.github.com/repos/sul-dlss/github_repo_1/zipball/v1.1',
                              published_at: 1.day.ago)
    end
  end
  let(:enabled) { true }

  before do
    allow(Github::AppService).to receive(:releases)
      .and_return([
                    # Before the created_at of the repository, so ignored
                    Github::AppService::Release.new(id: 1, tag: 'v1.0', name: 'First release',
                                                    zip_url: 'https://api.github.com/repos/sul-dlss/github_repo_1/zipball/v1.0',
                                                    published_at: 4.days.ago),
                    # Already exists in the database, so ignored
                    Github::AppService::Release.new(id: 2, tag: 'v1.1', name: 'Second release',
                                                    zip_url: 'https://api.github.com/repos/sul-dlss/github_repo_1/zipball/v1.1',
                                                    published_at: 1.day.ago),
                    Github::AppService::Release.new(id: 3, tag: 'v1.2', name: 'Third release',
                                                    zip_url: 'https://api.github.com/repos/sul-dlss/github_repo_1/zipball/v1.2',
                                                    published_at: Time.zone.now)
                  ])
  end

  context 'when depositing is not enabled for the repository' do
    let(:enabled) { false }

    it 'does not create any GithubRelease records' do
      expect { described_class.perform_now(github_repository:) }.not_to change(GithubRelease, :count)
      expect(Github::AppService).not_to have_received(:releases)
    end
  end

  context 'when depositing is enabled for the repository' do
    let(:enabled) { true }

    it 'does creates new GithubRelease records' do
      expect { described_class.perform_now(github_repository:) }.to change(GithubRelease, :count).by(1)
      new_release = GithubRelease.find_by(release_id: 3)
      expect(new_release.attributes.with_indifferent_access).to include(
        release_tag: 'v1.2',
        release_name: 'Third release',
        zip_url: 'https://api.github.com/repos/sul-dlss/github_repo_1/zipball/v1.2'
      )
    end
  end
end
