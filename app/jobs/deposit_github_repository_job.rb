# frozen_string_literal: true

# Job for depositing a GithubRepository.
class DepositGithubRepositoryJob < ApplicationJob
  def perform(work:, work_form:, deposit:, **args)
    # When editing a GithubRepository, deposit means the form is validated for deposit.
    # However, don't actually want to start accessioning; that is done when a release is created.
    DepositWorkJob.perform_now(work:, work_form:, deposit: false, **args)

    return unless deposit

    # work.github_deposit_enabled.nil? indicates the user has never made a choice to enable GitHub deposit.
    # For the initial deposit (not draft), GitHub deposit is enabled by default.
    # For subsequent edits, the user has a choice which is recorded in the work form.
    work.update_settings_from_form(work_form:)
    work.save!
  end
end
