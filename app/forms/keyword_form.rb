# frozen_string_literal: true

# Form for keywords
class KeywordForm < ApplicationForm
  attribute :text, :string
  validates :text, presence: true, if: :deposit?
end
