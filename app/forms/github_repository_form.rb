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

    errors.add(:repository, 'is not a valid GitHub repository') unless GithubService.repository?(repository)
  end
end
