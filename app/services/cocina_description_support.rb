# frozen_string_literal: true

# rubocop:disable Metrics/ClassLength
# Helpers for working with Cocina descriptions
class CocinaDescriptionSupport
  SOURCE = {
    code: 'marcrelator',
    uri: 'http://id.loc.gov/vocabulary/relators/'
  }.freeze

  ROLES = {
    author: {
      value: 'author',
      code: 'aut',
      uri: 'http://id.loc.gov/vocabulary/relators/aut',
      source: SOURCE
    },
    advisor: {
      value: 'advisor'
    },
    publisher: {
      value: 'publisher',
      code: 'pbl',
      uri: 'http://id.loc.gov/vocabulary/relators/pbl',
      source: SOURCE
    },
    # person roles
    composer: {
      value: 'composer',
      code: 'cmp',
      uri: 'http://id.loc.gov/vocabulary/relators/cmp',
      source: SOURCE
    },
    contributing_author: {
      value: 'contributing author',
      code: 'ctb',
      uri: 'http://id.loc.gov/vocabulary/relators/ctb',
      source: SOURCE
    },
    copyright_holder: {
      value: 'copyright holder',
      code: 'cph',
      uri: 'http://id.loc.gov/vocabulary/relators/cph',
      source: SOURCE
    },
    creator: {
      value: 'creator',
      code: 'cre',
      uri: 'http://id.loc.gov/vocabulary/relators/cre',
      source: SOURCE
    },
    data_collector: {
      value: 'data collector',
      code: 'com',

      uri: 'http://id.loc.gov/vocabulary/relators/com',
      source: SOURCE
    },
    data_contributor: {
      value: 'data contributor',
      code: 'dtc',
      uri: 'http://id.loc.gov/vocabulary/relators/dtc',
      source: SOURCE
    },
    editor: {
      value: 'editor',
      code: 'edt',
      uri: 'http://id.loc.gov/vocabulary/relators/edt',
      source: SOURCE
    },
    event_organizer: {
      value: 'event organizer',
      code: 'orm',
      uri: 'http://id.loc.gov/vocabulary/relators/orm',
      source: SOURCE
    },
    interviewee: {
      value: 'interviewee',
      code: 'ive',
      uri: 'http://id.loc.gov/vocabulary/relators/ive',
      source: SOURCE
    },
    interviewer: {
      value: 'interviewer',
      code: 'ivr',
      uri: 'http://id.loc.gov/vocabulary/relators/ivr',
      source: SOURCE
    },
    performer: {
      value: 'performer',
      code: 'prf',
      uri: 'http://id.loc.gov/vocabulary/relators/prf',
      source: SOURCE
    },
    photographer: {
      value: 'photographer',
      code: 'pht',
      uri: 'http://id.loc.gov/vocabulary/relators/pht',
      source: SOURCE
    },
    primary_thesis_advisor: {
      value: 'primary thesis advisor',
      code: 'ths',
      uri: 'http://id.loc.gov/vocabulary/relators/ths',
      source: SOURCE
    },
    principal_investigator: {
      value: 'principal investigator',
      code: 'rth',
      uri: 'http://id.loc.gov/vocabulary/relators/rth',
      source: SOURCE
    },
    researcher: {
      value: 'researcher',
      code: 'res',
      uri: 'http://id.loc.gov/vocabulary/relators/res',
      source: SOURCE
    },
    software_developer: {
      value: 'software developer',
      code: 'prg',
      uri: 'http://id.loc.gov/vocabulary/relators/prg',
      source: SOURCE
    },
    speaker: {
      value: 'speaker',
      code: 'spk',
      uri: 'http://id.loc.gov/vocabulary/relators/spk',
      source: SOURCE
    },
    thesis_advisor: {
      value: 'thesis advisor',
      code: 'ths',
      uri: 'http://id.loc.gov/vocabulary/relators/ths',
      source: SOURCE
    },
    # organization roles
    # 'Conference' => '', # not a marcrelator role
    degree_granting_institution: {
      value: 'degree granting institution',
      code: 'dgg',
      uri: 'http://id.loc.gov/vocabulary/relators/dgg',
      source: SOURCE
    },
    # 'Event' => '', # not a marcrelator role
    funder: {
      value: 'funder',
      code: 'fnd',
      uri: 'http://id.loc.gov/vocabulary/relators/fnd',
      source: SOURCE
    },
    host_institution: {
      value: 'host institution',
      code: 'his',
      uri: 'http://id.loc.gov/vocabulary/relators/his',
      source: SOURCE
    },
    issuing_body: {
      value: 'issuing body',
      code: 'isb',
      uri: 'http://id.loc.gov/vocabulary/relators/isb',
      source: SOURCE
    },
    research_group: {
      value: 'research group',
      code: 'res',
      uri: 'http://id.loc.gov/vocabulary/relators/res',
      source: SOURCE
    },
    sponsor: {
      value: 'sponsor',
      code: 'spn',
      uri: 'http://id.loc.gov/vocabulary/relators/spn',
      source: SOURCE
    }
  }.freeze

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

  def self.contributors(contributors:) # rubocop:disable Metrics/AbcSize
    contributors.filter_map.with_index do |contributor, index|
      # First entered contributor is always status: "primary" (except for Publisher)
      primary = index.zero?
      if contributor.role_type == 'person' && (contributor.last_name.presence || contributor.orcid.presence)
        person_contributor(
          forename: contributor.first_name,
          surname: contributor.last_name,
          role: contributor.person_role,
          primary:,
          orcid: contributor.orcid
        )
      elsif contributor.role_type == 'organization' && contributor.organization_name.presence
        organization_contributor(
          org_name: contributor.organization_name,
          role: contributor.organization_role,
          primary: primary
        )
      end
    end
  end

  # @param surname [String] the surname of the person
  # @param forename [String] the forename of the person
  # @param role [String] the role of the person from ROLES
  # @param primary [Boolean] whether this is the first author
  # @param orcid [String] the ORCID of the person
  # @param affiliations [Array<Hash>] the affiliations of the person that can be passed to affiliation()
  def self.person_contributor(surname:, forename:, role:, primary: false, orcid: nil)
    {
      name: [
        {
          structuredValue: [
            { value: forename, type: ('forename' if forename.presence) }.compact,
            { value: surname, type: ('surname' if surname.presence) }.compact
          ].compact_blank
        }.compact
      ].compact_blank,
      type: 'person',
      role: [ROLES.fetch(role.to_sym)].compact,
      status: ('primary' if primary),
      identifier: [orcid_identifier(orcid)].compact
      # NOTE: affiliations.map { |affiliation_attrs| affiliation(**affiliation_attrs) }.presence
    }.compact
  end

  def self.organization_contributor(org_name:, role:, primary: false)
    {
      name: [{ value: org_name }.compact],
      type: 'organization',
      role: [role.presence ? ROLES.fetch(role.sub(' ', '_').to_sym) : nil].compact,
      status: ('primary' if primary)
    }.compact
  end

  def self.orcid_identifier(orcid)
    return unless orcid.presence

    {
      value: orcid.delete_prefix(Settings.orcid.url),
      type: 'ORCID',
      source: { uri: Settings.orcid.url }
    }
  end

  def self.note(type:, value:, label: nil)
    {
      type:,
      value:
    }.tap do |note|
      note[:displayLabel] = label if label
    end
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
# rubocop:enable Metrics/ClassLength
