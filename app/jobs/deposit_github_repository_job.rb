# frozen_string_literal: true

# Job for depositing a GithubRepository.
class DepositGithubRepositoryJob < ApplicationJob
  def perform(work:, deposit:, **args)
    # When editing a GithubRepository, deposit means the form is validated for deposit.
    # However, don't actually want to start accessioning; that is done when a release is created.
    DepositWorkJob.perform_now(work:, deposit: false, **args)

    # This is a temporary approach to enabling github_deposit_enabled.
    # It will eventually be moved to the GithubRepositoryWorkForm.
    work.update!(github_deposit_enabled: true) if deposit
  end
end
