# frozen_string_literal: true

# Form for a related link
class RelatedLinkForm < ApplicationForm
  attribute :text, :string
  attribute :url, :string
  validates :url, url: true, unless: ->(link) { link.text.blank? }
end
