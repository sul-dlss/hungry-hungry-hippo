# frozen_string_literal: true

module Elements
  module Forms
    # Component for a toggle option
    class ToggleOptionComponent < ApplicationComponent
      def initialize(form:, field_name:, label:, value:, data:, label_data:) # rubocop:disable Metrics/ParameterLists
        @form = form
        @field_name = field_name
        @label = label
        @value = value
        @data = data
        @label_data = label_data
        super()
      end

      attr_reader :form, :field_name, :label, :value, :data, :label_data
    end
  end
end
