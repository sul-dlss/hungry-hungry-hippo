# frozen_string_literal: true

module Elements
  module Forms
    # Base component for all form fields.
    class FieldComponent < ApplicationComponent
      def initialize(form:, field_name:, required: false, hidden_label: false, label: nil, help_text: nil, # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength, Metrics/AbcSize
                     disabled: false, hidden: false, data: {}, input_data: {}, placeholder: nil, width: nil,
                     label_classes: [], container_classes: [], input_classes: [], tooltip: nil, caption: nil,
                     error_classes: [], readonly: false, mark_required: false)
        @form = form
        @field_name = field_name
        @required = required
        @mark_required = mark_required
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
        @caption = caption
        @error_classes = error_classes
        @readonly = readonly
        super()
      end

      attr_reader :form, :field_name, :required, :help_text, :hidden_label, :label, :hidden, :disabled, :data,
                  :placeholder, :width, :label_classes, :input_data, :tooltip, :caption, :readonly

      def help_text_id
        @help_text_id ||= form.field_id(field_name, 'help')
      end

      def field_aria
        error_aria.tap do |arias|
          # Set aria-required if we want to indicate required, but the field
          # does not actually have a required attribute
          #
          # This is used for collection/work forms where we do server-side
          # validation and don't want to block form submission on empty fields
          arias[:required] = true if @mark_required
        end
      end

      def error_aria
        InvalidFeedbackSupport.arias_for(field_name:, form:).tap do |arias|
          arias[:describedby] = merge_actions(arias[:describedby], help_text_id) if help_text.present?
        end
      end

      def styles
        return if width.blank?

        "max-width: #{width}px;"
      end

      def container_classes
        merge_classes(@container_classes)
      end

      def input_classes
        merge_classes(@input_classes)
      end

      def error_classes
        merge_classes(@error_classes)
      end

      delegate :id, to: :form, prefix: true
    end
  end
end
