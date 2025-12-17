# frozen_string_literal: true

# Creates a collection report requested via the admin UI and emails it to the user.
class CollectionReportsJob < RetriableJob
  # @param [Admin::CollectionReportForm] collection_report_form
  # @param [User] current_user
  def perform(collection_report_form:, current_user:)
    # generate the collection report CSV
    csv = Admin::CollectionReport.call(collection_report_form:)

    CollectionReportsMailer.with(
      current_user:,
      csv:
    ).collection_report_email.deliver_now
  end
end
