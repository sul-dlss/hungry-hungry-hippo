# frozen_string_literal: true

# Form for an author
class AuthorForm < ApplicationForm
  attribute :first_name, :string
  validates :first_name, presence: true, on: :deposit, if: -> { person? }

  attribute :last_name, :string
  validates :last_name, presence: true, on: :deposit, if: -> { person? }

  validate :name_must_be_complete, if: :person?

  attribute :organization_name, :string
  validates :organization_name, presence: true, on: :deposit, if: -> { organization? }

  attribute :person_role, :string
  validates :person_role, presence: true, if: :person?

  attribute :organization_role, :string
  validates :organization_role, presence: true, unless: :person?

  attribute :role_type, :string, default: 'person'
  validates :role_type, inclusion: { in: %w[person organization] }

  attribute :with_orcid, :boolean, default: false
  attribute :orcid, :string, default: nil
  validates :orcid, format: { with: /\A\d{4}-\d{4}-\d{4}-\d{3}[0-9X]\z/ },
                    allow_blank: true,
                    if: :person?

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

  # check that both name parts are provided
  def name_must_be_complete
    return if first_name.blank? && last_name.blank?

    return if first_name.present? && last_name.present?

    if first_name.blank?
      errors.add(:first_name, "can't be blank")
    else
      errors.add(:last_name, "can't be blank")
    end
  end
end
