# frozen_string_literal: true

# Service for handling GitHub interactions.
class GithubService
  class RepositoryNotFound < StandardError; end

  Repository = Struct.new('Repository', :id, :name, :url, :description, keyword_init: true)

  def self.repository?(...)
    new.repository?(...)
  end

  def self.repository(...)
    new.repository(...)
  end

  # @param repository [String] repository name (owner/repo), URL, or ID
  # @return [Boolean] true if the repository exists and public
  def repository?(repository)
    return false if repository.blank?

    normalized_repository = normalized_repository_for(repository)

    client.repository?(normalized_repository)
  end

  # @param repository [String] repository name (owner/repo), URL, or ID
  # @return [Repository] the repository object if it exists and public, otherwise nil
  # @raise [RepositoryNotFound] if the repository does not exist or is not public
  def repository(repository)
    client.repository(normalized_repository_for(repository)).then do |repository_response|
      Repository.new(id: repository_response.id, name: repository_response.full_name,
                     url: repository_response.html_url, description: repository_response.description)
    end
  rescue Octokit::NotFound, Octokit::InvalidRepository
    raise RepositoryNotFound, "Repository '#{repository}' not found or is not public"
  end

  private

  def client
    @client ||= if Rails.env.development?
                  Octokit::Client.new
                else
                  Octokit::Client.new(client_id: Settings.github.client_id,
                                      client_secret: Settings.github.client_secret)
                end
  end

  def normalized_repository_for(repository)
    return repository if repository.is_a?(Integer)
    return repository.to_i if repository.match?(/^\d+$/)

    repository.split('/').last(2).join('/')
  end
end
