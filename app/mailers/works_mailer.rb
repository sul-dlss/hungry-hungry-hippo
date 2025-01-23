# frozen_string_literal: true

# Sends email notifications about works
class WorksMailer < ApplicationMailer
  before_action :set_work
  before_action :set_work_presenter

  # For when the accessioning of the first version is completed.
  def deposited_email
    mail(to: @user.email_address, subject: "Your deposit, #{@work.title}, is published in the SDR")
  end

  # For when the accessioning of subsequent version is completed.
  def new_version_deposited_email
    mail(to: @user.email_address, subject: "Updates to #{@work.title} have been deposited in the SDR")
  end
end
