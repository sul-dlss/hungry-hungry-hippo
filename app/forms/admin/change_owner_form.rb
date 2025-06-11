# frozen_string_literal: true

module Admin
  # Admin form object for changing the ownership of a work.
  class ChangeOwnerForm < ApplicationForm
    attribute :sunetid, :string
    attribute :name, :string
    attribute :content_id, :integer
    attribute :work_form

    def owner
      @owner ||= User.find_or_create_by!(email_address: "#{sunetid}#{::User::EMAIL_SUFFIX}", name:)
    end
  end
end
