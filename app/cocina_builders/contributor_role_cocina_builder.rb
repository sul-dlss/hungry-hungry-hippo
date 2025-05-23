# frozen_string_literal: true

# Generates contributor role
class ContributorRoleCocinaBuilder # rubocop:disable Metrics/ClassLength
  SOURCE = {
    code: 'marcrelator',
    uri: 'http://id.loc.gov/vocabulary/relators/'
  }.freeze

  ROLES = {
    # both organization and person roles
    author: {
      value: 'author',
      code: 'aut',
      uri: 'http://id.loc.gov/vocabulary/relators/aut',
      source: SOURCE
    },
    contributing_author: {
      value: 'contributor',
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
    data_collector: {
      value: 'compiler',
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
    event_organizer: {
      value: 'organizer',
      code: 'orm',
      uri: 'http://id.loc.gov/vocabulary/relators/orm',
      source: SOURCE
    },
    researcher: {
      value: 'researcher',
      code: 'res',
      uri: 'http://id.loc.gov/vocabulary/relators/res',
      source: SOURCE
    },
    # person roles
    advisor: {
      value: 'advisor'
    },
    composer: {
      value: 'composer',
      code: 'cmp',
      uri: 'http://id.loc.gov/vocabulary/relators/cmp',
      source: SOURCE
    },
    creator: {
      value: 'creator',
      code: 'cre',
      uri: 'http://id.loc.gov/vocabulary/relators/cre',
      source: SOURCE
    },
    editor: {
      value: 'editor',
      code: 'edt',
      uri: 'http://id.loc.gov/vocabulary/relators/edt',
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
      value: 'degree supervisor',
      code: 'dgs',
      uri: 'http://id.loc.gov/vocabulary/relators/dgs',
      source: SOURCE
    },
    principal_investigator: {
      value: 'research team head',
      code: 'rth',
      uri: 'http://id.loc.gov/vocabulary/relators/rth',
      source: SOURCE
    },
    publisher: {
      value: 'publisher',
      code: 'pbl',
      uri: 'http://id.loc.gov/vocabulary/relators/pbl',
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
      value: 'degree committee member',
      code: 'dgc',
      uri: 'http://id.loc.gov/vocabulary/relators/dgc',
      source: SOURCE
    },
    # organization roles
    conference: {
      value: 'conference'
    },
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

    ROLES[role_key]
  end

  attr_reader :role

  def role_key
    role.tr(' ', '_').to_sym
  end
end
