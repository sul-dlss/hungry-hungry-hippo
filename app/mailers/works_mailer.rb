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

  def managers_depositing_email
    (@collection.managers - Array(params[:current_user])).each do |user|
      @user = user
      mail(to: @user.email_address, subject: "Item deposit completed in the #{@collection.title} collection")
    end
  end

  def ownership_changed_email
    mail(to: @user.email_address, subject: "Ownership of #{@work.title} has been changed")
  end

  def share_added_email
    @share = params[:share]
    mail(to: @share.user.email_address,
         subject: 'Someone has shared a work with you in the Stanford Digital Repository')
  end
end
