# frozen_string_literal: true

# Form for a contributor affiliation
# This form is used to collect information about an affiliation for a contributor
# It includes fields for the institution, department, and ROR identifier
class AffiliationForm < ApplicationForm
  attribute :institution, :string
  validates :institution, presence: true

  attribute :uri, :string
  validates :uri, presence: true, if: ->(affiliation) { affiliation.institution.present? }
  # validates :uri, format: { with: /\Ahttps:\/\/ror\.org\/0\w{6}\z/,
  #                           message: I18n.t('contributors.validation.affiliations.uri.invalid') },
  #                 allow_blank: true
  attribute :department, :string

  def empty?
    institution.blank? && uri.blank?
  end
end
