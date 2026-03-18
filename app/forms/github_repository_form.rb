# frozen_string_literal: true

# Form for a GitHub Repository
class GithubRepositoryForm < ApplicationForm
  # <owner>/<repo> or URL
  attribute :repository, :string
  validates :repository,
            presence: { message: I18n.t('github_repository_form.validations.repository.blank') }
  validate :valid_repository

  attribute :collection_druid, :string

  def valid_repository
    return if repository.blank?

    return if Github::AppService.repository?(repository)

    errors.add(:repository,
               I18n.t('github_repository_form.validations.repository.invalid'))
  end
end
