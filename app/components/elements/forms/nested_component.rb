# frozen_string_literal: true

module Elements
  module Forms
    # Encapsulates a nested form, including adding and removing nested models.
    class NestedComponent < ApplicationComponent
      def initialize(form:, model_class:, field_name:, form_component:)
        @form = form
        @model_class = model_class
        @field_name = field_name.to_s
        @form_component = form_component
        super()
      end

      attr_reader :form, :model_class, :form_component

      def body_id
        "card-body-#{@field_name}"
      end

      def header_label
        model_class.model_name.plural.humanize
      end

      # Return the field name with empty square brackets to mimic nested attributes for
      # ActiveModel models if field_name is plural
      def field_name
        (plural_field_name? ? "#{@field_name}[]" : @field_name).to_sym
      end

      private

      def plural_field_name?
        @field_name == @field_name.pluralize
      end
    end
  end
end
