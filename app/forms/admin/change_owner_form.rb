# frozen_string_literal: true

module Admin
  # Admin form object for changing the ownership of a work.
  class ChangeOwnerForm < ApplicationForm
    attribute :sunetid, :string
    # validates_with Admin::ChangeOwnerFormValidator

    attribute :content_id, :integer
    attribute :work_form

    def owner
      @owner ||= User.find_by_sunetid(sunetid:)
    end
  end
end
