# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GithubService, :vcr do
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
        expect { described_class.repository('sul-dlss/non-existent-repo') }.to raise_error(GithubService::RepositoryNotFound)
      end
    end

    context 'when the repository is private' do
      it 'raises RepositoryNotFound' do
        expect { described_class.repository('sul-dlss/google-books') }.to raise_error(GithubService::RepositoryNotFound)
      end
    end

    context 'when the repository is malformed' do
      it 'raises RepositoryNotFound' do
        expect { described_class.repository('foo') }.to raise_error(GithubService::RepositoryNotFound)
      end
    end
  end
end
