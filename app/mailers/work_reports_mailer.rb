# frozen_string_literal: true

# Sends email notifications about works
class WorkReportsMailer < ApplicationMailer
  def work_report_email
    @user = params[:current_user]
    @csv = params[:csv]

    attachments['item_report.csv'] = { mime_type: 'text/csv', content: @csv }
    mail(to: @user.email_address, subject: 'Item report is ready')
  end
end
