# frozen_string_literal: true

module CocinaGenerators
  # Generates Cocina Description
  class Description
    def self.person_contributor(...)
      PersonContributor.call(...)
    end

    def self.organization_contributor(...)
      OrganizationContributor.call(...)
    end
  end
end
