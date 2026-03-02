# frozen_string_literal: true

# Form for a GitHub Repository
class GithubRepositoryForm < ApplicationForm
  # <owner>/<repo> or URL
  attribute :repository, :string
  validates :repository, presence: true
  validate :valid_repository

  attribute :collection_druid, :string

  def valid_repository
    return if repository.blank?

    return if Github::AppService.repository?(repository)

    errors.add(:repository,
               'Enter a valid link or owner/name of a public GitHub repository.')
  end
end
