# frozen_string_literal: true

# Form for a related link
class RelatedLinkForm < ApplicationForm
  attribute :text, :string
  attribute :url, :string
  validates :url, presence: true, on: :deposit, unless: ->(link) { link.text.blank? }
end
