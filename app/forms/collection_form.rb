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
  attribute :default_license

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
end

def duration_must_be_present
  return if release_duration.present?

  errors.add(:release_duration, 'select a valid duration for release')
end
