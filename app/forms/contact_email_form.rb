# frozen_string_literal: true

# Form for contact emails
class ContactEmailForm < ApplicationForm
  attribute :email, :string
  validates :email, presence: true, format: {
    with: URI::MailTo::EMAIL_REGEXP
  }
end
