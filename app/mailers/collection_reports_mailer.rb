# frozen_string_literal: true

# Sends email notifications about collections
class CollectionReportsMailer < ApplicationMailer
  def collection_report_email
    @user = params[:current_user]
    @csv = params[:csv]

    attachments['collection_report.csv'] = { mime_type: 'text/csv', content: @csv }
    mail(to: @user.email_address, subject: 'Collection report is ready')
  end
end
