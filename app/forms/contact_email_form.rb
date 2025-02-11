# frozen_string_literal: true

# Form for contact emails
class ContactEmailForm < ApplicationForm
  attribute :email, :string
  validates :email, presence: true, on: :deposit
  validates :email, format: {
    with: URI::MailTo::EMAIL_REGEXP,
    allow_blank: true,
    message: 'must provide a valid email address' # rubocop:disable Rails/I18nLocaleTexts
  }
end
