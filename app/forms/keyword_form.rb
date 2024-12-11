# frozen_string_literal: true

# Form for keywords
class KeywordForm < ApplicationForm
  attribute :text, :string
  validates :text, presence: true, if: :deposit?
  attribute :uri, :string
  validates :uri, url: true, allow_blank: true
  attribute :cocina_type, :string
end
