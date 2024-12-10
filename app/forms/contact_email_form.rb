# frozen_string_literal: true

# Form for contact emails
class ContactEmailForm < ApplicationForm
  attribute :email, :string
  validates :email, presence: true, if: :deposit?
  validates :email, format: {
    with: URI::MailTo::EMAIL_REGEXP,
    allow_blank: true
  }
end
