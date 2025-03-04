# frozen_string_literal: true

# Sends email notifications about collections
class CollectionsMailer < ApplicationMailer
  before_action :set_collection
  before_action :set_user

  def invitation_to_deposit_email
    mail(to: @user.email_address,
         subject: "Invitation to deposit to the #{@collection.title} collection in the SDR")
  end

  def deposit_access_removed_email
    return unless @collection.email_depositors_status_changed

    mail(to: @user.email_address, subject: "Your Depositor permissions for the #{@collection.title} " \
                                           'collection in the SDR have been removed')
  end

  def manage_access_granted_email
    # Don't send invitation of the user created the collection
    return if @user == @collection.user

    mail(to: @user.email_address, subject: "You are invited to participate as a Manager in the #{@collection.title} " \
                                           'collection in the SDR')
  end

  def review_access_granted_email
    mail(to: @user.email_address, subject: "You are invited to participate as a Reviewer in the #{@collection.title} " \
                                           'collection in the SDR')
  end

  def participants_changed_email
    return unless @collection.email_when_participants_changed

    (@collection.managers + @collection.reviewers).uniq.each do |user|
      @user = user
      mail(to: @user.email_address, subject: "Participant changes for the #{@collection.title} collection in the SDR")
    end
  end

  def first_version_created_email
    mail(to: Settings.notifications.admin_email, subject: 'A new collection has been created')
  end

  private

  def set_user
    @user = params[:user]
  end

  def set_collection
    @collection = params[:collection]
  end
end
