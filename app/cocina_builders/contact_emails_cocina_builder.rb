# frozen_string_literal: true

# Generates the Cocina parameters for contact emails.
class ContactEmailsCocinaBuilder
  def self.call(...)
    new(...).call
  end

  def initialize(contact_emails:)
    @contact_emails = contact_emails
  end

  def call
    contact_emails.map do |contact_email|
      # Since contact_email is either a Hash or an instance of ContactEmailForm,
      # we need to make it a hash of the attributes if it's a ContactEmailForm
      contact_email = contact_email.attributes if contact_email.respond_to?(:attributes)
      next if contact_email['email'].blank?

      {
        value: contact_email['email'],
        type: 'email',
        displayLabel: 'Contact'
      }
    end.compact_blank.uniq
  end

  private

  attr_reader :contact_emails
end
