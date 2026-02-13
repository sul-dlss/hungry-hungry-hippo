# frozen_string_literal: true

module Github
  # Service for handling GitHub interactions.
  class AppService
    class RepositoryNotFound < StandardError; end

    Repository = Struct.new('Repository', :id, :name, :url, :description, keyword_init: true)
    Release = Struct.new('Release', :id, :name, :tag, :zip_url, :published_at)

    def self.repository?(...)
      new.repository?(...)
    end

    def self.repository(...)
      new.repository(...)
    end

    def self.releases(...)
      new.releases(...)
    end

    # @param repository [String] repository name (owner/repo), URL, or ID
    # @return [Boolean] true if the repository exists and public
    def repository?(repository)
      return false if repository.blank?

      normalized_repository = normalized_repository_for(repository)

      client.repository?(normalized_repository)
    end

    # @param repository [String] repository name (owner/repo), URL, or ID
    # @return [Repository] repository object if it exists and public
    # @raise [RepositoryNotFound] if the repository does not exist or is not public
    def repository(repository)
      client.repository(normalized_repository_for(repository)).then do |repository_response|
        Repository.new(id: repository_response.id, name: repository_response.full_name,
                       url: repository_response.html_url, description: repository_response.description)
      end
    rescue Octokit::NotFound, Octokit::InvalidRepository
      raise RepositoryNotFound, "Repository '#{repository}' not found or is not public"
    end

    # @param repository [String] repository name (owner/repo), URL, or ID
    # @return [Array<Release>] releases for the repository ordered by published date ascending
    # @raise [RepositoryNotFound] if the repository does not exist or is not public
    def releases(repository)
      client.releases(normalized_repository_for(repository)).sort_by(&:published_at).map do |release|
        Release.new(id: release.id, name: release.name, tag: release.tag_name, zip_url: release.zipball_url,
                    published_at: release.published_at)
      end
    rescue Octokit::NotFound, Octokit::InvalidRepository
      raise RepositoryNotFound, "Repository '#{repository}' not found or is not public"
    end

    private

    def client
      @client ||= if Rails.env.production?
                    Octokit::Client.new(access_token: installation_token)
                  else
                    Octokit::Client.new
                  end.tap do |client|
                    client.auto_paginate = true
                  end
    end

    def installation_token
      # Get installation access token
      client = Octokit::Client.new(bearer_token: jwt)
      token_response = client.create_app_installation_access_token(Settings.github.installation_id)
      token_response.token
    end

    def jwt
      private_key = OpenSSL::PKey::RSA.new(Base64.decode64(Settings.github.private_key))
      payload = {
        iat: Time.now.to_i,
        exp: Time.now.to_i + (10 * 60),
        iss: Settings.github.app_id
      }
      JWT.encode(payload, private_key, 'RS256')
    end

    def normalized_repository_for(repository)
      return repository if repository.is_a?(Integer)
      return repository.to_i if repository.match?(/^\d+$/)

      repository.split('/').last(2).join('/')
    end
  end
end
