# frozen_string_literal: true

# Form for a contributor
class ContributorForm < ApplicationForm
  accepts_nested_attributes_for :affiliations

  before_validation do
    blank_affiliations = affiliations_attributes.select(&:empty?)
    next if blank_affiliations.empty?

    self.affiliations_attributes = affiliations_attributes - blank_affiliations
  end

  attribute :first_name, :string
  attribute :last_name, :string

  validate :name_must_be_complete, if: :person?
  validate :name_must_be_complete_on_deposit, on: :deposit, if: :person?

  attribute :organization_name, :string
  validates :organization_name, presence: true, on: :deposit, if: -> { organization? }

  attribute :person_role, :string
  validates :person_role, presence: true, if: :person?

  attribute :organization_role, :string
  validates :organization_role, presence: true, unless: :person?

  # True when the organization_role is degree_granting_institution
  # and organization_name is Stanford University
  attribute :stanford_degree_granting_institution, :boolean, default: true

  # Department, institute, center
  # Only when stanford_degree_granting_institution is true
  attribute :suborganization_name, :string

  attribute :role_type, :string, default: 'person'
  validates :role_type, inclusion: { in: %w[person organization] }

  attribute :with_orcid, :boolean, default: true
  attribute :orcid, :string, default: nil
  validates :orcid, format: { with: /\A\d{4}-\d{4}-\d{4}-\d{3}[0-9X]\z/,
                              message: I18n.t('contributors.validation.orcid.invalid') },
                    allow_blank: true,
                    if: -> { person? && with_orcid }
  validates :orcid, presence: true, on: :deposit, if: -> { person? && with_orcid? }

  # When true, indicates that the contributor is required by the collection.
  attribute :collection_required, :boolean, default: false

  def person?(with_names: false)
    return false if role_type != 'person'
    return true unless with_names

    first_name.present? || last_name.present?
  end

  def organization?(with_names: false)
    return false if role_type != 'organization'
    return true unless with_names

    organization_name.present?
  end

  def with_orcid?
    with_orcid
  end

  def empty?
    !(person?(with_names: true) || organization?(with_names: true))
  end

  # Override serializable_hash to include nested attributes
  # This is used by the WorkFormSerializer to serialize the form.
  def serializable_hash(*)
    super(include: self.class.nested_attributes)
  end

  private

  # Name validation:
  # If part of a name is provided the whole name must be provided.
  # If depositing, the whole name must be provided.
  def name_must_be_complete_on_deposit
    return unless first_name.blank? && last_name.blank?
    # orcid validation will report an error, so we don't need to report an error here.
    return if with_orcid? && orcid.blank?

    errors.add(:first_name, I18n.t('contributors.validation.first_name.blank'))
    errors.add(:last_name, I18n.t('contributors.validation.last_name.blank'))
  end

  def name_must_be_complete # rubocop:disable Metrics/AbcSize
    return if first_name.blank? && last_name.blank?

    return if first_name.present? && last_name.present?

    if first_name.blank?
      errors.add(:first_name, I18n.t('contributors.validation.first_name.blank'))
    elsif !with_orcid?
      # Orcids can provide only a single name so we don't require last name if with_orcid is true
      errors.add(:last_name, I18n.t('contributors.validation.last_name.blank'))
    end
  end
end
