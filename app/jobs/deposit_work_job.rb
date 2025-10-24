# frozen_string_literal: true

# Invokes the work depositor asynchronously
class DepositWorkJob < ApplicationJob
  # @param [WorkForm] work_form
  # @param [Work] work
  # @param [Boolean] deposit if true and review is not requested, deposit the work; otherwise, leave as draft
  # @param [Boolean] request_review if true, request view of the work
  # @param [User] current_user
  def perform(work_form:, work:, deposit:, request_review:, current_user:)
    WorkDepositor.call(work_form:, work:, deposit:, request_review:, current_user:)
  end
end
