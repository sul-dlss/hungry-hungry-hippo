# frozen_string_literal: true

# Form for an author or non-author contributor
class ContributorForm < ApplicationForm
  attribute :role_type, :string

  attribute :person_role, :string
  validates :person_role, presence: true, if: :person?

  attribute :organization_role, :string
  validates :organization_role, presence: true, unless: :person?

  attribute :with_orcid, :boolean, default: false
  attribute :orcid, :string, default: nil

  attribute :first_name, :string
  validates :first_name, presence: true, if: :person?

  attribute :last_name, :string
  validates :last_name, presence: true, if: :person?

  validates :orcid, format: { with: %r{\Ahttps://(.*\.)?orcid.org/\d{4}-\d{4}-\d{4}-\d{3}[0-9X]\z},
                              message: I18n.t('works.edit.fields.contributors.orcid.error') },
                    allow_blank: true,
                    if: :person?

  attribute :organization_name, :string
  validates :organization_name, presence: true, unless: :person?

  def person?
    role_type == 'person'
  end
end
