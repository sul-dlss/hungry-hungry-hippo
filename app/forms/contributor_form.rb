# frozen_string_literal: true

# Form for a contributor
class ContributorForm < ApplicationForm
  has_many :affiliations, prepopulate_count: 1, prepopulate_if_empty: true

  before_validation do
    non_blank_affiliations = affiliations.reject(&:empty?)
    next if non_blank_affiliations.length == affiliations.length

    affiliations.clear
    non_blank_affiliations.each { |affiliation| affiliations << affiliation }
  end

  attribute :first_name, :string
  attribute :last_name, :string

  validate :name_must_be_complete, if: :person?
  validate :name_must_be_complete_on_deposit, on: :deposit, if: :person?

  attribute :organization_name, :string
  validates :organization_name,
            presence: { message: I18n.t('validations.fields.contributors.organization_name.blank') },
            on: :deposit,
            if: -> { organization? }

  attribute :person_role, :string
  validates :person_role,
            presence: { message: I18n.t('validations.fields.contributors.person_role.blank') },
            if: :person?

  attribute :organization_role, :string
  validates :organization_role,
            presence: { message: I18n.t('validations.fields.contributors.organization_role.blank') },
            unless: :person?

  # True when the organization_role is degree_granting_institution
  # and organization_name is Stanford University
  attribute :stanford_degree_granting_institution, :boolean, default: true

  # Department, institute, center
  # Only when stanford_degree_granting_institution is true
  attribute :suborganization_name, :string

  attribute :role_type, :string, default: 'person'
  validates :role_type,
            inclusion: {
              in: %w[person organization],
              message: I18n.t('validations.fields.contributors.role_type.inclusion')
            }

  attribute :with_orcid, :boolean, default: true
  attribute :orcid, :string, default: nil
  validates :orcid, format: { with: /\A\d{4}-\d{4}-\d{4}-\d{3}[0-9X]\z/,
                              message: I18n.t('validations.fields.contributors.orcid.invalid') },
                    allow_blank: true,
                    if: -> { person? && with_orcid }
  validates :orcid,
            presence: { message: I18n.t('validations.fields.contributors.orcid.blank') },
            on: :deposit,
            if: -> { person? && with_orcid? }

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

  def prepopulate!
    super
    return self if empty?
    return self unless affiliations.to_a.all?(&:empty?)

    affiliations.clear
    self
  end

  def empty?
    !(person?(with_names: true) || organization?(with_names: true))
  end

  private

  # Name validation:
  # If part of a name is provided the whole name must be provided.
  # If depositing, the whole name must be provided.
  def name_must_be_complete_on_deposit
    return unless first_name.blank? && last_name.blank?
    # orcid validation will report an error, so we don't need to report an error here.
    return if with_orcid? && orcid.blank?

    errors.add(:first_name, I18n.t('validations.fields.contributors.first_name.blank'))
    errors.add(:last_name, I18n.t('validations.fields.contributors.last_name.blank'))
  end

  def name_must_be_complete # rubocop:disable Metrics/AbcSize
    return if first_name.blank? && last_name.blank?

    return if first_name.present? && last_name.present?

    if first_name.blank?
      errors.add(:first_name, I18n.t('validations.fields.contributors.first_name.blank'))
    elsif !with_orcid?
      # Orcids can provide only a single name so we don't require last name if with_orcid is true
      errors.add(:last_name, I18n.t('validations.fields.contributors.last_name.blank'))
    end
  end
end
