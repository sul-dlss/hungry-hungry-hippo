# frozen_string_literal: true

# Sends email notifications about reviews
class ReviewsMailer < ApplicationMailer
  before_action :set_work
  before_action :set_work_presenter, only: [:approved_email]

  def submitted_email
    mail(to: @user.email_address, subject: 'Your deposit is submitted and waiting for approval')
  end

  def rejected_email
    mail(to: @user.email_address, subject: 'Your deposit has been reviewed and returned')
  end

  def approved_email
    mail(to: @user.email_address, subject: 'Your deposit has been reviewed and approved')
  end

  def pending_email
    @user = params[:user]
    mail(to: @user.email_address, subject: "Item ready for review in the #{@collection.title} collection")
  end
end
