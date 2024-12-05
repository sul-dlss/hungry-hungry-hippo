# frozen_string_literal: true

module Elements
  module Forms
    # Encapsulates a repeatable nested form, including adding and removing nested models.
    # NOTE: Use the `NestedComponentPresenter` to invoke this component; do not directly instantiate it.
    class RepeatableNestedComponent < ApplicationComponent
      def initialize(form:, model_class:, field_name:, form_component:, hidden_label: false, bordered: true) # rubocop:disable Metrics/ParameterLists
        @form = form
        @model_class = model_class
        @field_name = field_name
        @form_component = form_component
        @hidden_label = hidden_label
        @bordered = bordered
        super()
      end

      attr_reader :form, :model_class, :field_name, :form_component, :hidden_label

      def add_button_label
        "+ Add another #{model_class.model_name.singular.humanize(capitalize: false)}"
      end

      def classes
        merge_classes(%w[mb-3 p-3 row], bordered_classes)
      end

      def bordered_classes
        return [] unless @bordered

        %w[border border-3 border-light-subtle border-opacity-75]
      end

      def label_text
        model_class.model_name.plural.humanize
      end
    end
  end
end
