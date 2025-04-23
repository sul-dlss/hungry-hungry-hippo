# frozen_string_literal: true

# Generates contributor role
class ContributorRoleCocinaBuilder # rubocop:disable Metrics/ClassLength
  SOURCE = {
    code: 'marcrelator',
    uri: 'http://id.loc.gov/vocabulary/relators/'
  }.freeze

  AUTHOR_PARAMS = {
    value: 'author',
    code: 'aut',
    uri: 'http://id.loc.gov/vocabulary/relators/aut',
    source: SOURCE
  }

  CONTRIBUTING_AUTHOR_PARAMS = {
    value: 'contributor',
    code: 'ctb',
    uri: 'http://id.loc.gov/vocabulary/relators/ctb',
    source: SOURCE
  }

  COPYRIGHT_HOLDER_PARAMS = {
    value: 'copyright holder',
    code: 'cph',
    uri: 'http://id.loc.gov/vocabulary/relators/cph',
    source: SOURCE
  }

  DATA_COLLECTOR_PARAMS = {
    value: 'compiler',
    code: 'com',
    uri: 'http://id.loc.gov/vocabulary/relators/com',
    source: SOURCE
  }

  DATA_CONTRIBUTOR_PARAMS = {
    value: 'data contributor',
    code: 'dtc',
    uri: 'http://id.loc.gov/vocabulary/relators/dtc',
    source: SOURCE
  }

  EVENT_ORGANIZER_PARAMS = {
    value: 'organizer',
    code: 'orm',
    uri: 'http://id.loc.gov/vocabulary/relators/orm',
    source: SOURCE
  }

  # Note the person and organization can have roles that map to the same code, e.g., 'res'
  PERSON_ROLES =
    {
      author: AUTHOR_PARAMS,
      advisor: {
        value: 'advisor'
      },
      composer: {
        value: 'composer',
        code: 'cmp',
        uri: 'http://id.loc.gov/vocabulary/relators/cmp',
        source: SOURCE
      },
      contributing_author: CONTRIBUTING_AUTHOR_PARAMS,
      copyright_holder: COPYRIGHT_HOLDER_PARAMS,
      creator: {
        value: 'creator',
        code: 'cre',
        uri: 'http://id.loc.gov/vocabulary/relators/cre',
        source: SOURCE
      },
      data_collector: DATA_COLLECTOR_PARAMS,
      data_contributor: DATA_CONTRIBUTOR_PARAMS,
      editor: {
        value: 'editor',
        code: 'edt',
        uri: 'http://id.loc.gov/vocabulary/relators/edt',
        source: SOURCE
      },
      event_organizer: EVENT_ORGANIZER_PARAMS,
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
      principal_investigator: {
        value: 'research team head',
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
        value: 'programmer',
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
      }
    }.freeze

  # ORGANIZATION_ROLES = [
  #   ['Research group', 'research_group'],
  #   ['Sponsor', 'sponsor']
  # ].freeze

  ORGANIZATION_ROLES = {
    author: AUTHOR_PARAMS,
    conference: {
      value: 'conference'
    },
    contributing_author: CONTRIBUTING_AUTHOR_PARAMS,
    copyright_holder: COPYRIGHT_HOLDER_PARAMS,
    data_collector: DATA_COLLECTOR_PARAMS,
    data_contributor: DATA_CONTRIBUTOR_PARAMS,
    degree_granting_institution: {
      value: 'degree granting institution',
      code: 'dgg',
      uri: 'http://id.loc.gov/vocabulary/relators/dgg',
      source: SOURCE
    },
    distributor: {
      value: 'provider',
      code: 'prv',
      uri: 'http://id.loc.gov/vocabulary/relators/prv',
      source: SOURCE
    },
    event: {
      value: 'event'
    },
    event_organizer: EVENT_ORGANIZER_PARAMS,
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
      value: 'researcher',
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

  def self.call(...)
    new(...).call
  end

  def initialize(role:)
    @role = role
  end

  def call
    return if role.nil?

    PERSON_ROLES[role_key] || ORGANIZATION_ROLES[role_key]
  end

  attr_reader :role

  def role_key
    @role_key ||= role.tr(' ', '_').to_sym
  end
end
