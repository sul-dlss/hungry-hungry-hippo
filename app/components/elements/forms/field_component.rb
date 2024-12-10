# frozen_string_literal: true

module Elements
  module Forms
    # Base component for all form fields.
    class FieldComponent < ApplicationComponent
      def initialize(form:, field_name:, required: false, hidden_label: false, label: nil, help_text: nil, # rubocop:disable Metrics/ParameterLists
                     disabled: false, hidden: false, data: {}, placeholder: nil, width: nil)
        @form = form
        @field_name = field_name
        @required = required
        @hidden_label = hidden_label
        @label = label
        @help_text = help_text
        @hidden = hidden
        @disabled = disabled
        @data = data
        @placeholder = placeholder
        @width = width
        super()
      end

      attr_reader :form, :field_name, :required, :help_text, :hidden_label, :label, :hidden, :disabled, :data,
                  :placeholder, :width

      def help_text_id
        @help_text_id ||= form.field_id(field_name, 'help')
      end

      def field_aria
        return if @help_text.blank?

        { describedby: help_text_id }
      end

      def styles
        return if width.blank?

        "width: #{width}px;"
      end
    end
  end
end
