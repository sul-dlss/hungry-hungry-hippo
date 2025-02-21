# frozen_string_literal: true

module Elements
  module Forms
    # Base component for all form fields.
    class FieldComponent < ApplicationComponent
      def initialize(form:, field_name:, required: false, hidden_label: false, label: nil, help_text: nil, # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
                     disabled: false, hidden: false, data: {}, input_data: {}, placeholder: nil, width: nil,
                     label_classes: [], container_classes: [], input_classes: [], tooltip: nil, render_errors: true)
        @form = form
        @field_name = field_name
        @required = required
        @hidden_label = hidden_label
        @label = label
        @help_text = help_text
        @hidden = hidden
        @disabled = disabled
        @data = data
        @input_data = input_data
        @placeholder = placeholder
        @width = width
        @label_classes = label_classes
        @container_classes = container_classes
        @input_classes = input_classes
        @tooltip = tooltip
        @render_errors = render_errors
        super()
      end

      attr_reader :form, :field_name, :required, :help_text, :hidden_label, :label, :hidden, :disabled, :data,
                  :placeholder, :width, :label_classes, :input_data, :tooltip, :render_errors

      def help_text_id
        @help_text_id ||= form.field_id(field_name, 'help')
      end

      def field_aria
        return if help_text.blank?

        { describedby: help_text_id }
      end

      def styles
        [width_styles, error_styles].join(' ')
      end

      def container_classes
        merge_classes(@container_classes)
      end

      def input_classes
        merge_classes(@input_classes)
      end

      def width_styles
        return if width.blank?

        "max-width: #{width}px;"
      end

      def error_styles
        return if render_errors

        # This removes the exclamation mark from the input field for short fields that it obscures
        'background-image: none; padding-right: 0;'
      end

      delegate :id, to: :form, prefix: true
    end
  end
end
