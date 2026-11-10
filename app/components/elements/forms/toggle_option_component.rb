# frozen_string_literal: true

module Elements
  module Forms
    # Component for a toggle option
    class ToggleOptionComponent < ApplicationComponent
      def initialize(form:, field_name:, label:, value:, data: {}, position: :left) # rubocop:disable Metrics/ParameterLists
        raise ArgumentError, 'position must be :left or :right' unless %i[left right].include?(position)

        @form = form
        @field_name = field_name
        @label = label
        @value = value
        @data = data
        @position = position
        super()
      end

      attr_reader :form, :field_name, :label, :value, :data

      # The component library's toggle-radio styles round each option, so no rounding classes are added here.
      def label_classes
        'btn'
      end
    end
  end
end
