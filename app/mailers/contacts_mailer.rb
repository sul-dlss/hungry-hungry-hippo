# frozen_string_literal: true

# Mailer for sending contact SDR emails
class ContactsMailer < ApplicationMailer
  def jira_email
    @name = params[:name]
    @affiliation = params[:affiliation]
    @message = params[:message]
    @collections = format_collections(params[:collections])

    mail(to: [Settings.jira_email, Settings.support_email],
         from: params[:email_address],
         subject: params[:help_how])
  end

  def format_collections(collections)
    collections.map { |collection| I18n.t("contact_form.collections.#{collection}.label") }.join('; ')
  end
end
