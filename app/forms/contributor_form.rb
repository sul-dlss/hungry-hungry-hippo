# frozen_string_literal: true

# Form for a contributor
class ContributorForm < ApplicationForm
  attribute :first_name, :string
  validates :first_name, presence: true, on: :deposit, if: :validate_name_on_deposit?
  validates :first_name, presence: true, if: :validate_name?

  attribute :last_name, :string
  validates :last_name, presence: true, on: :deposit, if: :validate_name_on_deposit?
  validates :last_name, presence: true, if: :validate_name?

  validate :name_must_be_complete, if: :person?

  attribute :organization_name, :string
  validates :organization_name, presence: true, on: :deposit, if: -> { organization? }

  attribute :person_role, :string
  validates :person_role, presence: true, if: :person?

  attribute :organization_role, :string
  validates :organization_role, presence: true, unless: :person?

  # True when the organization_role is degree_granting_institution
  # and organization_name is Stanford University
  attribute :stanford_degree_granting_institution, :boolean, default: false

  # Department, institute, center
  # Only when stanford_degree_granting_institution is true
  attribute :suborganization_name, :string

  attribute :role_type, :string, default: 'person'
  validates :role_type, inclusion: { in: %w[person organization] }

  attribute :with_orcid, :boolean, default: true
  attribute :orcid, :string, default: nil
  validates :orcid, format: { with: /\A\d{4}-\d{4}-\d{4}-\d{3}[0-9X]\z/ },
                    allow_blank: true,
                    if: -> { person? && with_orcid }
  validates :orcid, presence: true, on: :deposit, if: -> { person? && with_orcid? }

  def person?(with_names: false)
    return false if role_type != 'person'
    return true unless with_names

    first_name.present? && last_name.present?
  end

  def organization?(with_names: false)
    return false if role_type != 'organization'
    return true unless with_names

    organization_name.present?
  end

  def with_orcid?
    with_orcid
  end

  # If any part of a name is provided, then first and last must be provided.
  def name_must_be_complete
    return if first_name.blank? && last_name.blank?

    return if first_name.present? && last_name.present?

    if first_name.blank?
      errors.add(:first_name, "can't be blank")
    else
      errors.add(:last_name, "can't be blank")
    end
  end

  def validate_name_on_deposit?
    person? && !with_orcid?
  end

  def validate_name?
    return false unless person?

    return false unless with_orcid?

    orcid.present?
  end
end
