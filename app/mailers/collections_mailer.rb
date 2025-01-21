# frozen_string_literal: true

# Sends email notifications about collections
class CollectionsMailer < ApplicationMailer
  before_action :set_collection
  before_action :set_user

  def invitation_to_deposit_email
    mail(to: @user.email_address,
         subject: "Invitation to deposit to the #{@collection.title} collection in the SDR")
  end

  def manage_access_granted_email
    mail(to: @user.email_address, subject: "You are invited to participate as a Manager in the #{@collection.title} " \
                                           'collection in the SDR')
  end

  private

  def set_user
    @user = params[:user]
  end

  def set_collection
    @collection = params[:collection]
  end
end
