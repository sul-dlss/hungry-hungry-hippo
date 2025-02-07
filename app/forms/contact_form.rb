# frozen_string_literal: true

# Form object for the contact form
class ContactForm < ApplicationForm
  HELP_HOW_CHOICES = [
    'I want to become an SDR depositor',
    'I want to report a problem',
    'I want to ask a question',
    'I want to provide feedback',
    'Request access to another collection'
  ].freeze

  attribute :name, :string
  attribute :email_address, :string
  attribute :affiliation, :string
  attribute :help_how, :string
  attribute :message, :string
  attribute :welcome, :boolean, default: false

  def welcome?
    welcome
  end
end
