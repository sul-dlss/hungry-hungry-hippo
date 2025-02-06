# frozen_string_literal: true

# Mailer for sending contact us emails
class ContactsMailer < ApplicationMailer
  def jira_email
    @name = params[:name]
    @affiliation = params[:affiliation]
    @message = params[:message]

    mail(to: [Settings.jira_email, Settings.support_email],
         from: params[:email_address],
         subject: params[:help_how])
  end
end
