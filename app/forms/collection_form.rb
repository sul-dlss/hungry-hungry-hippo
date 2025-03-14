# frozen_string_literal: true

# Form for a Collection
class CollectionForm < ApplicationForm
  accepts_nested_attributes_for :related_links, :contact_emails, :managers, :depositors, :reviewers

  def self.immutable_attributes
    ['druid']
  end

  attribute :access, :string, default: 'world'
  attribute :custom_rights_statement_instructions, :string
  attribute :custom_rights_statement_option, :string, default: 'no'
  attribute :default_license, :string
  attribute :deposits_contact_email, :string
  attribute :description, :string # Collection description maps to the cocina abstract
  attribute :doi_option, :string, default: 'yes'
  attribute :druid, :string
  attribute :email_depositors_status_changed, :boolean, default: true
  attribute :email_when_participants_changed, :boolean, default: true
  attribute :license, :string
  attribute :license_option, :string, default: 'required'
  attribute :lock, :string
  attribute :provided_custom_rights_statement, :string
  attribute :release_duration, :string
  attribute :release_option, :string, default: 'immediate'
  attribute :review_enabled, :boolean, default: false
  attribute :title, :string
  attribute :version, :integer, default: 1
  attribute :work_subtypes, array: true, default: -> { [] }
  attribute :work_type, :string

  alias id druid

  # rubocop:disable Rails/I18nLocaleTexts
  validates :access, inclusion: { in: %w[world stanford depositor_selects] }
  validates :custom_rights_statement_instructions, presence: true,
                                                   if: -> { custom_rights_statement_option == 'depositor_selects' }
  validates :custom_rights_statement_option, presence: true, inclusion: { in: %w[no provided depositor_selects] }
  validates :default_license, presence: true, if: -> { license_option == 'depositor_selects' }
  validates :deposits_contact_email, format: {
    with: URI::MailTo::EMAIL_REGEXP, allow_blank: true, message: I18n.t('contact_email.validation.email.invalid')
  }
  validates :description, presence: true
  validates :doi_option, inclusion: { in: %w[yes no depositor_selects] }
  validates :license, presence: true, if: -> { license_option == 'required' }
  validates :license_option, inclusion: { in: %w[required depositor_selects] }
  validates :managers_attributes, length: { minimum: 1, message: 'must have at least one manager' }
  validates :provided_custom_rights_statement, presence: true, if: -> { custom_rights_statement_option == 'provided' }
  validates :release_duration, presence: { message: 'select a valid duration for release' },
                               if: -> { release_option == 'depositor_selects' }
  validates :release_option, inclusion: { in: %w[immediate depositor_selects] }
  validates :title, presence: true
  # rubocop:enable Rails/I18nLocaleTexts

  before_validation do
    self.custom_rights_statement_instructions = LinebreakSupport.normalize(custom_rights_statement_instructions)

    self.provided_custom_rights_statement = LinebreakSupport.normalize(provided_custom_rights_statement)

    self.work_type = work_type.presence

    blank_managers = managers_attributes.select(&:empty?)
    self.managers_attributes = managers_attributes - blank_managers if blank_managers.present?

    work_subtypes.compact_blank!
  end

  def persisted?
    druid.present?
  end

  def selected_license
    if license_option == 'required' && license != License::NO_LICENSE_ID
      license
    elsif license_option == 'depositor_selects' && default_license.present?
      default_license
    end
  end
end
