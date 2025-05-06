# frozen_string_literal: true

module Cocina
  # Methods used to extract data from Cocina objects that are used outside To*Form classes.
  # Extraction methods that are only used in To*Form classes should NOT be here.
  class Parser
    def self.title_for(cocina_object:)
      cocina_object.description.title.first.value
    end

    def self.collection_druid_for(cocina_object:)
      cocina_object.structural.isMemberOf.first
    end

    def self.doi_for(cocina_object:)
      cocina_object.identification.doi
    end

    def self.version_for(cocina_object:)
      cocina_object.version
    end

    def self.apo_for(cocina_object:)
      cocina_object.administrative.hasAdminPolicy
    end

    def self.copyright_for(cocina_object:)
      cocina_object.access.copyright
    end
  end
end
