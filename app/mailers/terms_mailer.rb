# frozen_string_literal: true

# Sends email notifications about having agreed to the terms of deposit
class TermsMailer < ApplicationMailer
  def reminder_email
    @user = params[:user]
    mail(to: @user.email_address, subject: 'Annual Notice of the Stanford Digital Repository (SDR) Terms of Deposit')
  end
end
