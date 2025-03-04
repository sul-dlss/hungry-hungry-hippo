# frozen_string_literal: true

module Elements
  module Forms
    # Component for a toggle option
    class ToggleOptionComponent < ApplicationComponent
      def initialize(form:, field_name:, label:, value:, data: {})
        @form = form
        @field_name = field_name
        @label = label
        @value = value
        @data = data
        super()
      end

      attr_reader :form, :field_name, :label, :value, :data
    end
  end
end
