# frozen_string_literal: true

# Generates contributor role
class ContributorRoleCocinaBuilder # rubocop:disable Metrics/ClassLength
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
    conference: {
      value: 'conference'
    },
    degree_granting_institution: {
      value: 'degree granting institution',
      code: 'dgg',
      uri: 'http://id.loc.gov/vocabulary/relators/dgg',
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
    role.sub(' ', '_').to_sym
  end
end
