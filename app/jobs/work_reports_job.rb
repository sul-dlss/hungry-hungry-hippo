# frozen_string_literal: true

# Creates a work item report requested via the admin UI and emails it to the user.
class WorkReportsJob < ApplicationJob
  # @param [Admin::WorkReportForm] work_report_form
  # @param [User] current_user
  def perform(work_report_form:, current_user:)
    # generate the work report CSV
    debugger
    csv = Admin::WorkReport.call(work_report_form:)

    WorkReportsMailer.with(
      current_user:,
      csv:
    ).work_report_email.deliver_later
  end
end
