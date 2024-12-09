# frozen_string_literal: true

# Form for an author or non-author contributor
class ContributorForm < ApplicationForm
  attribute :role_type, :string
  attribute :person_role, :string
  attribute :organization_role, :string
  attribute :with_orcid, :boolean, default: false
  attribute :orcid, :string, default: nil
  attribute :first_name, :string
  attribute :last_name, :string
  validates :orcid, format: { with: %r{\Ahttps://(.*\.)?orcid.org/\d{4}-\d{4}-\d{4}-\d{3}[0-9X]\z},
                              message: I18n.t('works.edit.fields.contributors.orcid.error') },
                    allow_blank: true,
                    if: :person?
  attribute :organization_name, :string

  with_options(if: :deposit?) do |deposit|
    debugger
    deposit.validates :person_role, presence: true, if: :person?
    deposit.validates :organization_role, presence: true, unless: :person?
    deposit.validates :first_name, presence: true, if: :person?
    deposit.validates :last_name, presence: true, if: :person?
    deposit.validates :organization_name, presence: true, unless: :person?
  end

  def person?
    role_type == 'person'
  end
end
