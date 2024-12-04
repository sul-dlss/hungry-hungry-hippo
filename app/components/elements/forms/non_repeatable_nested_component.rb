# frozen_string_literal: true

module Elements
  module Forms
    # Encapsulates a non-repeatable nested form.
    # NOTE: Use the `NestedComponentPresenter` to invoke this component; do not directly instantiate it.
    class NonRepeatableNestedComponent < ApplicationComponent
      def initialize(form:, model_class:, field_name:, form_component:)
        @form = form
        @model_class = model_class
        @field_name = field_name
        @form_component = form_component
        super()
      end

      attr_reader :form, :model_class, :field_name, :form_component

      def header_label
        helpers.t("#{field_name}.edit.legend")
      end
    end
  end
end
