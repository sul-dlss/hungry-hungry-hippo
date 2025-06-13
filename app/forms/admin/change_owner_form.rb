# frozen_string_literal: true

module Admin
  # Admin form object for changing the ownership of a work.
  class ChangeOwnerForm < ApplicationForm
    attribute :sunetid, :string
    attribute :work_form
    attribute :content_id, :integer
  end
end
