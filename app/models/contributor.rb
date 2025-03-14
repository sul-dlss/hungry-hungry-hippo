# frozen_string_literal: true

# Model for a contributor specified for a collection.
# These will be added by default to a new work and are required.
class Contributor < ApplicationRecord
  belongs_to :collection

  enum :role_type, { person: 'person', organization: 'organization' }
end
