# frozen_string_literal: true

module Elements
  module Forms
    # Component for form select fields
    # rubocop:disable Metrics/ParameterLists
    class SelectFieldComponent < ApplicationComponent
      def initialize(form:, field_name:, options:, required: false, hidden_label: false,
                     label: nil, help_text: nil, prompt: false)
        @form = form
        @field_name = field_name
        @options = options
        @required = required
        @hidden_label = hidden_label
        @label = label
        @help_text = help_text
        @prompt = prompt
        super()
      end

      attr_reader :form, :field_name, :options, :required, :hidden_label, :label, :help_text, :prompt

      def help_text_id
        @help_text_id ||= form.field_id(field_name, 'help')
      end

      def field_aria
        return if @help_text.blank?

        { describedby: help_text_id }
      end
    end
    # rubocop:enable Metrics/ParameterLists
  end
end
