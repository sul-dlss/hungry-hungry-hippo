# frozen_string_literal: true

module Elements
  module Forms
    # Encapsulates a repeatable nested form, including adding and removing nested models.
    # NOTE: Use the `NestedComponentPresenter` to invoke this component; do not directly instantiate it.
    class RepeatableNestedComponent < ApplicationComponent
      def initialize(form:, model_class:, field_name:, form_component:, hidden_label: false, bordered: true, # rubocop:disable Metrics/ParameterLists
                     reorderable: false, single_field: false, fieldset_classes: [])
        @form = form
        @model_class = model_class
        @field_name = field_name
        @form_component = form_component
        @hidden_label = hidden_label
        @bordered = bordered
        @reorderable = reorderable
        @single_field = single_field
        @fieldset_classes = fieldset_classes
        super()
      end

      attr_reader :form, :model_class, :field_name, :form_component, :hidden_label, :fieldset_classes

      def label_text
        helpers.t("#{field_name}.edit.legend")
      end

      def tooltip
        helpers.t("#{field_name}.edit.tooltip_html", default: nil)
      end

      def bordered?
        @bordered
      end

      def add_button_label
        "+ Add another #{model_class.model_name.singular.humanize(capitalize: false)}"
      end

      def container_classes
        merge_classes(%w[container], bordered? ? [] : %w[p-0])
      end

      def row_classes
        merge_classes(%w[row form-instance],
                      bordered? ? %w[p-3 border border-3 border-light-subtle border-opacity-75 mb-3] : [])
      end

      def nested_buttons_classes
        merge_classes(%w[col-md-auto d-flex],
                      single_field? ? %w[align-items-stretch] : %w[flex-column])
      end

      def add_button_classes
        'my-0'
      end

      def reorderable?
        @reorderable
      end

      def fieldset_data
        {
          controller: ['nested-form', reorderable? ? 'nested-form-reorder' : nil].compact.join(' '),
          nested_form_selector_value: '.form-instance'
        }
      end

      def single_field?
        # whether there is a single visible field in the form, to determine button placement
        @single_field
      end
    end
  end
end
