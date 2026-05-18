# frozen_string_literal: true

# Form for contact emails
class ContactEmailForm < ApplicationForm
  attribute :email, :string
  normalizes :email, with: ->(value) { value.strip }
  validates :email, presence: true, on: :deposit
  validates :email, format: {
    with: URI::MailTo::EMAIL_REGEXP,
    allow_blank: true,
    message: I18n.t('validations.fields.contact_email.email.invalid')
  }
end
