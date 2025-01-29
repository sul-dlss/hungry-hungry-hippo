# frozen_string_literal: true

# Form for a Collection
class CollectionForm < ApplicationForm
  accepts_nested_attributes_for :related_links, :contact_emails, :managers, :depositors

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
  validates :description, presence: true, on: :deposit

  attribute :access, :string, default: 'world'
  validates :access, inclusion: { in: %w[world stanford depositor_selects] }

  attribute :release_option, :string, default: 'immediate'
  validates :release_option, inclusion: { in: %w[immediate depositor_selects] }

  attribute :release_duration, :string
  with_options if: -> { release_option == 'depositor_selects' } do
    validates :release_duration, presence: true
    validates :release_duration, inclusion: { in: %w[six_months one_year two_years three_years] }
  end

  attribute :doi_option, :string, default: 'yes'
  validates :doi_option, inclusion: { in: %w[yes no depositor_selects] }
end
