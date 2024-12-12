# frozen_string_literal: true

# Form for an author contributor
class AuthorForm < ContributorForm
  attribute :first_name, :string
  validates :first_name, presence: true, if: -> { person? && deposit? }

  attribute :last_name, :string
  validates :last_name, presence: true, if: -> { person? && deposit? }

  attribute :organization_name, :string
  validates :organization_name, presence: true, if: -> { organization? && deposit? }

  attribute :role_type, :string

  def organization?
    role_type == 'organization'
  end
end
