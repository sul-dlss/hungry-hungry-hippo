# frozen_string_literal: true

# Form for a Collection
class CollectionForm < ApplicationForm
  has_many :related_links, prepopulate_if_empty: true
  has_many :contact_emails
  has_many :managers
  has_many :depositors
  has_many :reviewers
  has_many :contributors, prepopulate_count: 1, prepopulate_if_empty: true

  before_validation do
    non_blank_managers = managers.reject(&:empty?)
    next if non_blank_managers.length == managers.length

    managers.clear
    non_blank_managers.each { |manager| managers << manager }
  end
  validates :managers,
            length: {
              minimum: 1,
              message: I18n.t('collection_form.fields.managers.validations.minimum')
            }

  before_validation do
    non_blank_reviewers = reviewers.reject(&:empty?)
    next if non_blank_reviewers.length == reviewers.length

    reviewers.clear
    non_blank_reviewers.each { |reviewer| reviewers << reviewer }
  end

  before_validation if: :review_enabled do
    next if reviewers.present?

    # if the review workflow is on and there are not currently any reviewers added by the user,
    # any managers will be added as reviewers, see https://github.com/sul-dlss/hungry-hungry-hippo/issues/1710
    managers.each { |manager| reviewers.build(sunetid: manager.sunetid, name: manager.name) }
  end

  validates :reviewers,
            length: {
              minimum: 1,
              message: I18n.t('collection_form.fields.reviewers.validations.minimum')
            },
            if: -> { review_enabled }

  before_validation do
    non_blank_contributors = contributors.reject(&:empty?)
    next if non_blank_contributors.length == contributors.length

    contributors.clear
    non_blank_contributors.each { |contributor| contributors << contributor }
  end

  def self.immutable_attributes
    ['druid']
  end

  attribute :druid, :string
  alias id druid

  attribute :lock, :string

  attribute :version, :integer, default: 1

  attribute :title, :string
  validates :title, presence: { message: I18n.t('collection_form.fields.title.validations.blank') }

  # The Collection description maps to the cocina abstract
  attribute :description, :string
  validates :description, presence: { message: I18n.t('collection_form.fields.description.validations.blank') }

  attribute :access, :string, default: 'world'
  validates :access,
            inclusion: {
              in: %w[world stanford depositor_selects],
              message: I18n.t('collection_form.fields.access.validations.inclusion')
            }

  attribute :license_option, :string, default: 'required'
  validates :license_option,
            inclusion: {
              in: %w[required depositor_selects],
              message: I18n.t('collection_form.fields.license_option.validations.inclusion')
            }

  attribute :license, :string
  validates :license,
            presence: { message: I18n.t('collection_form.fields.license.validations.blank') },
            if: -> { license_option == 'required' }
  attribute :default_license, :string
  validates :default_license,
            presence: { message: I18n.t('collection_form.fields.default_license.validations.blank') },
            if: -> { license_option == 'depositor_selects' }

  attribute :custom_rights_statement_option, :string, default: 'no'
  validates :custom_rights_statement_option,
            presence: { message: I18n.t('collection_form.fields.custom_rights_statement_option.validations.blank') },
            inclusion: {
              in: %w[no provided depositor_selects],
              message: I18n.t('collection_form.fields.custom_rights_statement_option.validations.inclusion')
            }

  attribute :provided_custom_rights_statement, :string
  normalizes :provided_custom_rights_statement, with: ->(value) { LinebreakSupport.normalize(value) }
  validates :provided_custom_rights_statement,
            presence: {
              message: I18n.t('collection_form.fields.provided_custom_rights_statement.validations.blank')
            },
            if: -> { custom_rights_statement_option == 'provided' }

  attribute :custom_rights_statement_instructions, :string
  normalizes :custom_rights_statement_instructions, with: ->(value) { LinebreakSupport.normalize(value) }
  validates :custom_rights_statement_instructions,
            presence: {
              message: I18n.t('collection_form.fields.custom_rights_statement_instructions.validations.blank')
            },
            if: lambda {
              custom_rights_statement_option == 'depositor_selects'
            }

  attribute :release_option, :string, default: 'immediate'
  validates :release_option,
            inclusion: {
              in: %w[immediate depositor_selects],
              message: I18n.t('collection_form.fields.release_option.validations.inclusion')
            }

  attribute :release_duration, :string
  with_options if: -> { release_option == 'depositor_selects' } do
    validate :duration_must_be_present
  end

  attribute :doi_option, :string, default: 'yes'
  validates :doi_option,
            inclusion: {
              in: %w[yes no depositor_selects],
              message: I18n.t('collection_form.fields.doi_option.validations.inclusion')
            }

  attribute :review_enabled, :boolean, default: false
  attribute :github_deposit_enabled, :boolean, default: false
  attribute :article_deposit_enabled, :boolean, default: false

  attribute :email_when_participants_changed, :boolean, default: true
  attribute :email_depositors_status_changed, :boolean, default: true

  attribute :work_type, :string
  normalizes :work_type, with: ->(value) { value.presence }

  attribute :work_subtypes, array: true, default: -> { [] }
  before_validation { work_subtypes.compact_blank! }

  attribute :works_contact_email, :string
  validates :works_contact_email, format: {
    with: URI::MailTo::EMAIL_REGEXP,
    allow_blank: true,
    message: I18n.t('collection_form.fields.works_contact_email.validations.invalid')
  }

  attribute :apo, :string, default: Settings.apo

  def duration_must_be_present
    return if release_duration.present?

    errors.add(:release_duration, I18n.t('collection_form.fields.release_duration.validations.valid_duration'))
  end

  def selected_license
    if license_option == 'required' && license != License::NO_LICENSE_ID
      license
    elsif license_option == 'depositor_selects' && default_license.present?
      default_license
    end
  end
end
