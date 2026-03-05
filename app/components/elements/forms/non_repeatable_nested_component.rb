# frozen_string_literal: true

module Elements
  module Forms
    # Encapsulates a non-repeatable nested form.
    # NOTE: Use the `NestedComponentPresenter` to invoke this component; do not directly instantiate it.
    class NonRepeatableNestedComponent < ApplicationComponent
      def initialize(form:, model_class:, field_name:, form_component:, hidden_label: false, # rubocop:disable Metrics/ParameterLists
                     legend_classes: [], fieldset_classes: [], **form_component_args)
        @form = form
        @model_class = model_class
        @field_name = field_name
        @form_component = form_component
        @hidden_label = hidden_label
        @legend_classes = legend_classes
        @fieldset_classes = fieldset_classes
        @form_component_args = form_component_args
        super()
      end

      attr_reader :form, :model_class, :field_name, :form_component, :form_component_args, :hidden_label

      def label_text
        nested_form_translation(:legend)
      end

      def tooltip
        nested_form_translation(:tooltip_html)
      end

      def id
        field_name
      end

      private

      def nested_form_translation(key)
        helpers.t("#{form.object.locales_key}.nested_forms.#{field_name}.#{key}", default: nil) ||
          helpers.t("form.nested_forms.#{field_name}.#{key}", default: nil)
      end
    end
  end
end
