# frozen_string_literal: true

# Form for a related link
class RelatedLinkForm < ApplicationForm
  attribute :text, :string
  attribute :url, :string
  validates :url, presence: true

  # Make a fake ID so we can generate array-like form fields.
  def id
    Digest::MD5.hexdigest("#{url}#{text}")
  end
end
