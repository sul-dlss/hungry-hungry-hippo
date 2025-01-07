# frozen_string_literal: true

# Form for a related work
class RelatedWorkForm < ApplicationForm
  RELATIONSHIP_TYPES = [
    'supplement to',
    'supplemented by',
    'referenced by',
    'references',
    'derived from',
    'source of',
    'version of record',
    'identical to',
    'has version',
    'has original version',
    'preceded by',
    'succeeded by',
    'part of',
    'has part'
  ].freeze

  attribute :citation, :string
  attribute :identifier, :string
  attribute :relationship, :string
  validates :relationship, inclusion: { in: RELATIONSHIP_TYPES }, allow_blank: true
  attribute :use_citation, :boolean

  with_options(on: :deposit) do |deposit|
    deposit.validates :citation, absence: true, if: ->(related_work) { related_work.identifier.present? }
    deposit.validates :identifier, absence: true, if: ->(related_work) { related_work.citation.present? }
    deposit.validates :relationship, presence: true, if: (lambda do |related_work|
      related_work.citation.present? || related_work.identifier.present?
    end)
  end

  def to_s
    return if relationship.blank? # otherwise it will return " ()"

    "#{identifier.presence || citation} (#{relationship})"
  end
end
