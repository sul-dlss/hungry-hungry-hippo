# frozen_string_literal: true

# Form for an author or non-author contributor
class ContributorForm < ApplicationForm
  validate :name_must_be_complete

  attribute :role_type, :string

  attribute :person_role, :string
  validates :person_role, presence: true, if: :person?

  attribute :organization_role, :string
  validates :organization_role, presence: true, unless: :person?

  attribute :with_orcid, :boolean, default: false
  attribute :orcid, :string, default: nil

  attribute :first_name, :string
  attribute :last_name, :string

  validates :orcid, format: { with: %r{\Ahttps://(.*\.)?orcid.org/\d{4}-\d{4}-\d{4}-\d{3}[0-9X]\z},
                              message: I18n.t('works.edit.fields.contributors.orcid.error') },
                    allow_blank: true,
                    if: :person?

  attribute :organization_name, :string

  def person?
    role_type == 'person'
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
