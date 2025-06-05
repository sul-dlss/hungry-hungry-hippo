# frozen_string_literal: true

# Sends email notifications about works
class WorkReportsMailer < ApplicationMailer
  def work_report_email
    @user = params[:current_user]
    @csv = params[:csv]

    mail(to: @user.email_address, subject: 'Item report is ready')
    mail.attachments['item_report.csv'] = { content: StringIO.new(@csv) }
  end
end
