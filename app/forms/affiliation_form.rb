# frozen_string_literal: true

# Form for a contributor affiliation
# This form is used to collect information about an affiliation for a contributor
# It includes fields for the institution, department, and ROR identifier
class AffiliationForm < ApplicationForm
  attribute :institution, :string
  validates :institution, presence: true, if: -> { department.present? }
  validate :validate_institution

  attribute :uri, :string
  attribute :department, :string

  def validate_institution
    # uri must be present if institution is present.
    # However, error should be reported for institution, not uri.
    # This happens when the user types in the autocomplete field but does not select an item.
    return unless institution.present? && uri.blank?

    errors.add(:institution, 'must be selected from the list')
  end
end
