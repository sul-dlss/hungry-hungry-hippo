# frozen_string_literal: true

module Elements
  module Forms
    # Component for a set of checkboxes for a collection of objects
    # See https://api.rubyonrails.org/v8.0.0/classes/ActionView/Helpers/FormOptionsHelper.html#method-i-collection_checkboxes
    class InputCollectionCheckboxesComponent < BaseInputCollectionComponent
      def initialize(disabled_values: [], disabled_checkbox_classes: [], disabled_label_classes: [], **args)
        @disabled_values = disabled_values
        @disabled_checkbox_classes = disabled_checkbox_classes
        @disabled_label_classes = disabled_label_classes
        super(**args)
      end

      attr_reader :disabled_values

      def checkbox_classes_for(disabled)
        disabled ? disabled_checkbox_classes : checkbox_classes
      end

      def label_classes_for(disabled)
        disabled ? disabled_label_classes : label_classes
      end

      def checkbox_classes
        'form-check-input'
      end

      def disabled_checkbox_classes
        merge_classes(checkbox_classes, @disabled_checkbox_classes)
      end

      def label_classes
        'form-check-label'
      end

      def disabled_label_classes
        merge_classes(label_classes, @disabled_label_classes)
      end
    end
  end
end
