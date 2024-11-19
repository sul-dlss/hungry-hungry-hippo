# frozen_string_literal: true

# Helpers for working with Cocina descriptions
class CocinaDescriptionSupport
  # ROLES = {
  #   AUTHOR: {
  #     value: 'author',
  #     code: 'aut',
  #     uri: 'http://id.loc.gov/vocabulary/relators/aut',
  #     source: {
  #       code: 'marcrelator',
  #       uri: 'http://id.loc.gov/vocabulary/relators/'
  #     }
  #   },
  #   PUBLISHER: {
  #     value: 'publisher',
  #     code: 'pbl',
  #     uri: 'http://id.loc.gov/vocabulary/relators/pbl',
  #     source: {
  #       code: 'marcrelator',
  #       uri: 'http://id.loc.gov/vocabulary/relators/'
  #     }
  #   }
  # }.freeze

  def self.title(title:)
    [{ value: title }]
  end

  def self.related_links(related_links:)
    related_links.map do |related_link|
      {
        access: {
          url: [
            { value: related_link.url }
          ]
        }
      }.tap do |related_link_hash|
        next if (related_link_text = related_link.text).blank?

        related_link_hash[:title] = [{ value: related_link_text }]
      end
    end
  end

  # @param forename [String] the forename of the person
  # @param surname [String] the surname of the person
  # @param role [Symbol] the role of the person from ROLES
  # @param affiliations [Array<Hash>] the affiliations of the person that can be passed to affiliation()
  # def self.person_contributor(surname:, forename: '', role: :AUTHOR, affiliations: [])
  #   {
  #     name: [
  #       {
  #         structuredValue: [
  #           { value: forename, type: 'forename' },
  #           { value: surname, type: 'surname' }
  #         ]
  #       }
  #     ],
  #     type: 'person',
  #     role: [ROLES.fetch(role)],
  #     note: affiliations.map { |affiliation_attrs| affiliation(**affiliation_attrs) }.presence
  #   }.compact
  # end

  def self.note(type:, value:)
    {
      type:,
      value:
    }
  end

  # def self.event_date(date_type:, date_value:, type: 'deposit', date_encoding_code: 'edtf')
  #   {
  #     type:,
  #     date: [{
  #       value: date_value,
  #       type: date_type,
  #       encoding: { code: date_encoding_code }

  #     }]
  #   }
  # end

  # def self.event_contributor(contributor_name_value:, type: 'publication', contributor_type: 'organization',
  #                            role: :PUBLISHER)
  #   {
  #     type:,
  #     contributor: [
  #       {
  #         name: [
  #           {
  #             value: contributor_name_value
  #           }
  #         ],
  #         type: contributor_type,
  #         role: [ROLES.fetch(role)]
  #       }
  #     ]
  #   }
  # end

  # def self.subjects(values:)
  #   values.map do |value|
  #     {
  #       value:,
  #       type: 'topic'
  #     }
  #   end
  # end

  # def self.affiliation(organization:, ror_id: nil)
  #   {
  #     type: 'affiliation',
  #     value: organization
  #   }.tap do |affiliation|
  #     if ror_id
  #       affiliation[:identifier] = [{
  #         uri: ror_id,
  #         type: 'ROR',
  #         source: {
  #           code: 'ror'
  #         }
  #       }]
  #     end
  #   end
  # end

  # def self.related_resource_note(citation:)
  #   { type: 'preferred citation', value: citation }
  # end

  # def self.doi_identifier(doi:)
  #   return unless doi

  #   {
  #     value: doi,
  #     type: 'DOI',
  #     source: { code: 'doi' }
  #   }
  # end
end
