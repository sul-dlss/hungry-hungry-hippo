# frozen_string_literal: true

# Form for an author or non-author contributor
class ContributorForm < ApplicationForm
  attribute :role_type, :string
  attribute :role_term, :string
  attribute :person_role, :string
  validates :person_role, presence: true, if: :person?
  attribute :organization_role, :string
  validates :organization_role, presence: true, unless: :person?
  attribute :first_name, :string
  attribute :last_name, :string
  validates :first_name, presence: true, if: :person?
  validates :last_name, presence: true, if: :person?

  # attribute :orcid, :string

  # validates :orcid, format: { with: %r{\Ahttps://(.*\.)?orcid.org/\d{4}-\d{4}-\d{4}-\d{3}[0-9X]\z},
  #                             message: I18n.t('works.edit.fields.orcid.error') },
  #                   allow_nil: true, if: :person?
  # validates :orcid, absence: true, unless: :person?

  def person?
    role_type == 'person'
  end
end
