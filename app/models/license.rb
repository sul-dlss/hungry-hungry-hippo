# frozen_string_literal: true

class License < FrozenRecord::Base
  GROUPS = [
    'Creative Commons',
    'Open Data Commons (ODC) licenses',
    'Software Licenses',
    'Other'
  ].freeze
end
