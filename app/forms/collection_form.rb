# frozen_string_literal: true

# Form for a Collection
class CollectionForm < ApplicationForm
  accepts_nested_attributes_for :related_links, :contact_emails, :managers, :depositors, :reviewers

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
  attribute :email_when_participants_changed, :boolean, default: true
  attribute :email_depositors_status_changed, :boolean, default: true

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
