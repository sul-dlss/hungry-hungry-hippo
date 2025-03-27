# frozen_string_literal: true

# Form for contact emails
class ContactEmailForm < ApplicationForm
  attribute :email, :string
  validates :email, presence: true, on: :deposit
  validates :email, format: {
    with: URI::MailTo::EMAIL_REGEXP,
    allow_blank: true,
    message: I18n.t('contact_email.validation.email.invalid')
  }

  before_validation :strip_whitespace

  def empty?
    email.blank?
  end

  private

  def strip_whitespace
    email&.strip!
  end
end
