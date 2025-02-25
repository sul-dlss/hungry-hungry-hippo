# frozen_string_literal: true

# Form for a related link
class RelatedLinkForm < ApplicationForm
  attribute :text, :string
  validates :text, presence: true, if: ->(link) { link.url.present? }
  attribute :url, :string
  validates :url, url: true, unless: ->(link) { link.url.blank? && link.text.blank? }
end
