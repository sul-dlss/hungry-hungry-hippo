# frozen_string_literal: true

# Form for contact emails
class ContactEmailForm < ApplicationForm
  attribute :email, :string
  validates :email, presence: true, format: {
    with: /\A[^@]+@([a-z0-9-]+\.)+[a-z]{2,4}\z/
  }
end
