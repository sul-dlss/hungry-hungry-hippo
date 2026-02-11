# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Github::AppService, :vcr do
  describe '.repository?' do
    context 'when the repository exists and is public' do
      it 'returns true' do
        expect(described_class.repository?('sul-dlss/hungry-hungry-hippo')).to be true
      end
    end

    context 'when the repository does not exist' do
      it 'returns false' do
        expect(described_class.repository?('sul-dlss/non-existent-repo')).to be false
      end
    end

    context 'when the repository is private' do
      it 'returns false' do
        # Assuming 'octocat/PrivateRepo' is a private repository for testing purposes
        expect(described_class.repository?('sul-dlss/google-books')).to be false
      end
    end

    context 'when the input is blank' do
      it 'returns false' do
        expect(described_class.repository?('')).to be false
        expect(described_class.repository?(nil)).to be false
      end
    end
  end

  describe '.repository' do
    context 'when the repository exists and is public' do
      subject(:repository) { described_class.repository('sul-dlss/hungry-hungry-hippo') }

      it 'returns the repository object' do
        expect(repository)
          .to have_attributes(id: 881_494_248, name: 'sul-dlss/hungry-hungry-hippo',
                              url: 'https://github.com/sul-dlss/hungry-hungry-hippo',
                              description: 'Self-Deposit for the Stanford Digital Repository (SDR)')
      end
    end

    context 'when the repository does not exist' do
      it 'raises RepositoryNotFound' do
        expect { described_class.repository('sul-dlss/non-existent-repo') }.to raise_error(Github::AppService::RepositoryNotFound)
      end
    end

    context 'when the repository is private' do
      it 'raises RepositoryNotFound' do
        expect { described_class.repository('sul-dlss/google-books') }.to raise_error(Github::AppService::RepositoryNotFound)
      end
    end

    context 'when the repository is malformed' do
      it 'raises RepositoryNotFound' do
        expect { described_class.repository('foo') }.to raise_error(Github::AppService::RepositoryNotFound)
      end
    end
  end

  describe '.releases' do
    context 'when the repository exists and is public' do
      it 'returns the releases for the repository' do
        releases = described_class.releases('sul-dlss/hungry-hungry-hippo')
        expect(releases.length).to eq(1)
        expect(releases.first)
          .to have_attributes(id: 186_241_744, name: 'v0.1.0', tag: 'v0.1.0',
                              zip_url: 'https://api.github.com/repos/sul-dlss/hungry-hungry-hippo/zipball/v0.1.0',
                              published_at: Time.zone.parse('2024-11-19T16:54:06Z'))
      end
    end

    context 'when the repository does not exist' do
      it 'raises RepositoryNotFound' do
        expect { described_class.releases('sul-dlss/non-existent-repo') }.to raise_error(Github::AppService::RepositoryNotFound)
      end
    end

    context 'when the repository is private' do
      it 'raises RepositoryNotFound' do
        expect { described_class.releases('sul-dlss/google-books') }.to raise_error(Github::AppService::RepositoryNotFound)
      end
    end

    context 'when the repository is malformed' do
      it 'raises RepositoryNotFound' do
        expect { described_class.releases('foo') }.to raise_error(Github::AppService::RepositoryNotFound)
      end
    end
  end
end
