# frozen_string_literal: true

# Form for a Collection
class CollectionForm < ApplicationForm
  accepts_nested_attributes_for :related_links, :contact_emails, :managers, :depositors, :reviewers, :contributors

  before_validation do
    blank_managers = managers.select(&:empty?)
    next if blank_managers.empty?

    self.managers = managers - blank_managers
  end
  validates :managers, length: { minimum: 1, message: 'must have at least one manager' } # rubocop:disable Rails/I18nLocaleTexts

  before_validation do
    blank_reviewers = reviewers.select(&:empty?)
    next if blank_reviewers.empty?

    self.reviewers = reviewers - blank_reviewers
  end

  before_validation if: :review_enabled do
    next if reviewers.present?

    # if the review workflow is on and there are not currently any reviewers added by the user,
    # any managers will be added as reviewers, see https://github.com/sul-dlss/hungry-hungry-hippo/issues/1710
    self.reviewers = managers.map { |manager| ReviewerForm.new(sunetid: manager.sunetid, name: manager.name) }
  end

  validates :reviewers, length: { minimum: 1, message: 'must have at least one reviewer' }, # rubocop:disable Rails/I18nLocaleTexts
                        if: -> { review_enabled }

  before_validation do
    blank_contributors = contributors.select(&:empty?)
    next if blank_contributors.empty?

    self.contributors = contributors - blank_contributors
  end

  def self.immutable_attributes
    ['druid']
  end

  attribute :druid, :string
  alias id druid

  def persisted?
    druid.present?
  end

  attribute :lock, :string

  attribute :version, :integer, default: 1

  attribute :title, :string
  validates :title, presence: true

  # The Collection description maps to the cocina abstract
  attribute :description, :string
  validates :description, presence: true

  attribute :access, :string, default: 'world'
  validates :access, inclusion: { in: %w[world stanford depositor_selects] }

  attribute :license_option, :string, default: 'required'
  validates :license_option, inclusion: { in: %w[required depositor_selects] }

  attribute :license, :string
  validates :license, presence: true, if: -> { license_option == 'required' }
  attribute :default_license, :string
  validates :default_license, presence: true, if: -> { license_option == 'depositor_selects' }

  attribute :custom_rights_statement_option, :string, default: 'no'
  validates :custom_rights_statement_option, presence: true, inclusion: { in: %w[no provided depositor_selects] }

  attribute :provided_custom_rights_statement, :string
  validates :provided_custom_rights_statement, presence: true, if: -> { custom_rights_statement_option == 'provided' }
  before_validation do
    self.provided_custom_rights_statement = LinebreakSupport.normalize(provided_custom_rights_statement)
  end

  attribute :custom_rights_statement_instructions, :string
  validates :custom_rights_statement_instructions, presence: true, if: lambda {
    custom_rights_statement_option == 'depositor_selects'
  }
  before_validation do
    self.custom_rights_statement_instructions = LinebreakSupport.normalize(custom_rights_statement_instructions)
  end

  attribute :release_option, :string, default: 'immediate'
  validates :release_option, inclusion: { in: %w[immediate depositor_selects] }

  attribute :release_duration, :string
  with_options if: -> { release_option == 'depositor_selects' } do
    validate :duration_must_be_present
  end

  attribute :doi_option, :string, default: 'yes'
  validates :doi_option, inclusion: { in: %w[yes no depositor_selects] }

  attribute :review_enabled, :boolean, default: false
  attribute :github_deposit_enabled, :boolean, default: false
  attribute :article_deposit_enabled, :boolean, default: false

  attribute :email_when_participants_changed, :boolean, default: true
  attribute :email_depositors_status_changed, :boolean, default: true

  attribute :work_type, :string
  before_validation do
    self.work_type = work_type.presence
  end

  attribute :work_subtypes, array: true, default: -> { [] }
  before_validation { work_subtypes.compact_blank! }

  attribute :works_contact_email, :string
  validates :works_contact_email, format: {
    with: URI::MailTo::EMAIL_REGEXP, allow_blank: true, message: I18n.t('contact_email.validation.email.invalid')
  }

  attribute :apo, :string, default: Settings.apo

  def duration_must_be_present
    return if release_duration.present?

    errors.add(:release_duration, 'select a valid duration for release')
  end

  def selected_license
    if license_option == 'required' && license != License::NO_LICENSE_ID
      license
    elsif license_option == 'depositor_selects' && default_license.present?
      default_license
    end
  end
end
