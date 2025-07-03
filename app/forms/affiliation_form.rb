# frozen_string_literal: true

# Form for a contributor affiliation
# This form is used to collect information about an affiliation for a contributor
# It includes fields for the institution, department, and ROR identifier
class AffiliationForm < ApplicationForm
  attribute :institution, :string
  validates :institution, presence: true

  attribute :uri, :string
  validates :uri, presence: true, if: ->(affiliation) { affiliation.institution.present? }

  attribute :department, :string

  def empty?
    institution.blank? && uri.blank?
  end
end
