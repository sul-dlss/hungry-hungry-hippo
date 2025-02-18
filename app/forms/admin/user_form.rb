# frozen_string_literal: true

module Admin
  # Admin form object for searching for a user by SUNet ID.
  class UserForm < ApplicationForm
    attribute :sunetid, :string
  end
end
