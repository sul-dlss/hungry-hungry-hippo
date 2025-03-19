# frozen_string_literal: true

# Form for keywords
class KeywordForm < ApplicationForm
  attribute :text, :string
  validates :text, presence: true, on: :deposit
  # NOTE: These two attributes are parsed from the keyword resolution service
  #       response and injected into the form, and are entirely optional. If
  #       the resolution service fails or the user wants a keyword that cannot
  #       be resolved, we consider that acceptable. Thus, do not validate these
  #       fields.
  attribute :uri, :string
  attribute :cocina_type, :string

  def empty?
    text.blank?
  end
end
