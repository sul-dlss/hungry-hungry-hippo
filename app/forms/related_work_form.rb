# frozen_string_literal: true

# Form for a related work
class RelatedWorkForm < ApplicationForm
  RELATIONSHIP_TYPES = RelatedWorksCocinaBuilder::RELATION_TYPES.keys.freeze

  attribute :citation, :string
  attribute :identifier, :string
  attribute :relationship, :string
  validates :relationship, inclusion: { in: RELATIONSHIP_TYPES }, if: (lambda do |related_work|
    related_work.citation.present? || related_work.identifier.present?
  end)
  attribute :use_citation, :boolean, default: false

  with_options(on: :deposit) do |deposit|
    deposit.validates :citation, absence: true, if: ->(related_work) { related_work.identifier.present? }
    deposit.validates :identifier, absence: true, if: ->(related_work) { related_work.citation.present? }
  end

  def to_s
    identifier.presence || citation
  end
end
