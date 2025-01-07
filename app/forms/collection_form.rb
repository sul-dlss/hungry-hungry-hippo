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
end
