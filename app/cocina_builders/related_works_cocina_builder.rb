# frozen_string_literal: true

# Generates the Cocina parameters for related works.
class RelatedWorksCocinaBuilder
  def self.call(...)
    new(...).call
  end

  def initialize(related_works:)
    @related_works = related_works
  end

  def call
    related_works.map do |related_work|
      # NOTE: Sometimes this is an array of hashes and sometimes it's an array of RelatedLinkForm instances
      related_work = related_work.attributes if related_work.respond_to?(:attributes)
      next if related_work['citation'].blank? && related_work['identifier'].blank?

      related_work_params_for(related_work:)
    end.compact_blank
  end

  private

  attr_reader :related_works

  def related_work_params_for(related_work:)
    {
      type: related_work['relationship']
    }.compact.tap do |related_work_hash|
      if related_work['identifier'].present?
        related_work_hash[:identifier] =
          [{ uri: related_work['identifier'] }]
      end

      if related_work['citation'].present?
        related_work_hash[:note] = [{ type: 'preferred citation', value: related_work['citation'] }]
      end
    end
  end
end
