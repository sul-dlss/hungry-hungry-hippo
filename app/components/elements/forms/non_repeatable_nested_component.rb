# frozen_string_literal: true

module Elements
  module Forms
    # Encapsulates a non-repeatable nested form.
    # NOTE: Use the `NestedComponentPresenter` to invoke this component; do not directly instantiate it.
    class NonRepeatableNestedComponent < ApplicationComponent
      def initialize(form:, model_class:, field_name:, form_component:, hidden_label: false, # rubocop:disable Metrics/ParameterLists
                     legend_classes: [], **form_component_args)
        @form = form
        @model_class = model_class
        @field_name = field_name
        @form_component = form_component
        @hidden_label = hidden_label
        @legend_classes = legend_classes
        @form_component_args = form_component_args
        super()
      end

      attr_reader :form, :model_class, :field_name, :form_component, :form_component_args

      def header_label
        helpers.t("#{field_name}.edit.legend")
      end

      def legend_classes
        merge_classes('form-label', @legend_classes, @hidden_label ? 'visually-hidden' : nil)
      end
    end
  end
end
