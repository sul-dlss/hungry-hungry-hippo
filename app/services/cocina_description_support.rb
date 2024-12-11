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

  def self.contact_emails(contact_emails:)
    contact_emails.map do |contact_email|
      # Since contact_email is either a Hash or an instance of ContactEmailForm,
      # we need to make it a hash of the attributes if it's a ContactEmailForm
      contact_email = contact_email.attributes if contact_email.respond_to?(:attributes)
      next if contact_email['email'].blank?

      {
        value: contact_email['email'],
        type: 'email',
        displayLabel: 'Contact'
      }
    end.compact_blank
  end

  def self.keywords(keywords:) # rubocop:disable Metrics/AbcSize
    keywords.map do |keyword|
      # Since keyword is either a Hash or an instance of KeywordForm,
      # we need to make it a hash of the attributes if it's a KeywordForm
      keyword = keyword.attributes if keyword.respond_to?(:attributes)
      next if keyword['text'].blank?

      {
        value: keyword['text']
      }.tap do |keyword_hash|
        keyword_hash[:type] = keyword['cocina_type'] if keyword['cocina_type'].present?
        next if keyword['uri'].blank?

        keyword_hash[:uri] = keyword['uri']
        keyword_hash[:source] = { code: 'fast', uri: 'http://id.worldcat.org/fast/' }
      end
    end.compact_blank
  end

  def self.related_links(related_links:)
    related_links.map do |related_link|
      # NOTE: Sometimes this is an array of hashes and sometimes it's an array of RelatedLinkForm instances
      related_link = related_link.attributes if related_link.respond_to?(:attributes)
      next if related_link['url'].blank?

      {
        access: {
          url: [
            { value: related_link['url'] }
          ]
        }
      }.tap do |related_link_hash|
        next if (related_link_text = related_link['text']).blank?

        related_link_hash[:title] = [{ value: related_link_text }]
      end
    end.compact_blank
  end

  def self.related_works(related_works:) # rubocop:disable Metrics/AbcSize
    related_works.map do |related_work|
      # NOTE: Sometimes this is an array of hashes and sometimes it's an array of RelatedLinkForm instances
      related_work = related_work.attributes if related_work.respond_to?(:attributes)
      next if related_work['citation'].blank? && related_work['identifier'].blank?

      {
        type: related_work['relationship']
      }.tap do |related_work_hash|
        related_work_hash[:identifier] = [{ uri: related_work['identifier'] }] if related_work['identifier'].present?

        if related_work['citation'].present?
          related_work_hash[:note] = [{ type: 'preferred citation', value: related_work['citation'] }]
        end
      end
    end.compact_blank
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

  # @param date [String] the value of the date, e.g., '2024-03'
  # @param type [String] the type of the date, e.g., 'publication'
  # @param date_encoding_code [String] the encoding code for the date, e.g., 'edtf'
  # @param primary [Boolean] whether this is the primary date
  def self.event_date(date:, type:, date_encoding_code: 'edtf', primary: false)
    {
      type:,
      date: [
        {
          value: date,
          type: type,
          encoding: { code: date_encoding_code }

        }.tap do |date_params|
          date_params[:status] = 'primary' if primary
        end
      ]
    }
  end

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
