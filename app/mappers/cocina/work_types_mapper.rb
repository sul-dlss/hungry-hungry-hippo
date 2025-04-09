# frozen_string_literal: true

# The containing namespace for mappers indicates what is being mapped *to*
module Cocina
  # Maps work types and subtypes to Cocina
  class WorkTypesMapper
    RESOURCE_TYPE_SOURCE_LABEL = 'Stanford self-deposit resource types'
    DATACITE_SOURCE_LABEL = 'DataCite resource types'

    def self.call(...)
      new(...).call
    end

    def initialize(work_form:)
      @work_form = work_form
    end

    def call
      return [] unless work_type.presence

      self_deposit_resource_types + genres + resource_types + datacite_types
    end

    private

    attr_reader :work_form

    delegate :work_type, to: :work_form

    def work_subtypes
      @work_subtypes ||= work_form.work_subtypes + [work_form.other_work_subtype.presence].compact
    end

    def self_deposit_resource_types
      [
        {
          structuredValue: [self_deposit_resource_type_value] + self_deposit_resource_subtype_values,
          source: { value: RESOURCE_TYPE_SOURCE_LABEL },
          type: 'resource type'
        }
      ]
    end

    def self_deposit_resource_type_value
      { value: work_type, type: 'type' }
    end

    def self_deposit_resource_subtype_values
      work_subtypes.map do |subtype|
        { value: subtype, type: 'subtype' }
      end
    end

    def datacite_types
      value = types_to_resource_types.dig(work_type, 'datacite_type')
      return [] unless value

      [
        {
          value:,
          source: { value: DATACITE_SOURCE_LABEL },
          type: 'resource type'
        }
      ]
    end

    def genres
      return [] if work_type == 'Other'

      # Uniq avoids adding dupe genres when same genre is from type and subtype.
      ([work_type_genre].compact + work_subtypes_genres).flatten.uniq
    end

    def work_type_genre
      types_to_genres.dig(work_type, 'type')
    end

    def work_subtypes_genres
      # It's possible there is no genre found
      work_subtypes.flat_map { |subtype| types_to_genres.dig(work_type, 'subtypes', subtype) }.compact
    end

    def resource_types
      return [] if work_type == 'Other'

      # Uniq avoids adding dupe genres when same genre in from type and subtype.
      (work_type_resource_types + work_subtypes_resource_types).uniq
    end

    def work_type_resource_types
      types_to_resource_types.dig(work_type, 'type') || []
    end

    def work_subtypes_resource_types
      work_subtypes.flat_map do |subtype|
        Array(types_to_resource_types.dig(work_type, 'subtypes', subtype)).map do |resource_type|
          resource_type
        end
      end
    end

    def types_to_genres
      @@types_to_genres ||= YAML.load_file(Rails.root.join('config/mappings/types_to_genres.yml')) # rubocop:disable Style/ClassVars
    end

    def types_to_resource_types
      @@types_to_resource_types ||= YAML.load_file(Rails.root.join('config/mappings/types_to_resource_types.yml')) # rubocop:disable Style/ClassVars
    end
  end
end
