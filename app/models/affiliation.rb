# frozen_string_literal: true

# Model for an affiliation of a contributor.
class Affiliation < ApplicationRecord
  belongs_to :contributor

  validates :institution, presence: true
  validates :uri, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: false }
end
