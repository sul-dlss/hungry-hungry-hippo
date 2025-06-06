# frozen_string_literal: true

# The containing namespace for mappers indicates what is being mapped *to*
module Form
  # Maps work types.
  class WorkTypeMapper < BaseMapper
    def call
      if work_type == WorkType::OTHER
        return { work_type:, work_subtypes: [],
                 other_work_subtype: work_subtypes.first }
      end
      { work_type:, work_subtypes: }
    end

    private

    # @return [Cocina::Models::DescriptiveValue] descriptive value for Stanford self-deposit resource types
    def self_deposit_form
      @self_deposit_form ||= cocina_object.description.form.find do |form|
        form&.source&.value == Cocina::WorkTypesMapper::RESOURCE_TYPE_SOURCE_LABEL
      end
    end

    def self_deposit_values
      @self_deposit_values ||= self_deposit_form&.structuredValue || []
    end

    def work_type
      @work_type ||= self_deposit_values.find { |value| value[:type] == 'type' }&.value
    end

    def work_subtypes
      @work_subtypes ||= self_deposit_values.filter_map { |value| value[:type] == 'subtype' && value.value.presence }
    end
  end
end
