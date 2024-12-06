# frozen_string_literal: true

module Elements
  module Forms
    # Base component for a set of inputs for a collection, e.g. checkboxes or radio buttons
    class BaseInputCollectionComponent < ApplicationComponent
      def initialize(form:, field_name:, input_collection:, value_method: :to_s, text_method: :to_s, # rubocop:disable Metrics/ParameterLists
                     div_classes: [], input_data: {})
        @form = form
        @field_name = field_name
        @input_collection = input_collection
        @value_method = value_method
        @text_method = text_method
        @div_classes = div_classes
        @input_data = input_data
        super()
      end

      attr_reader :form, :field_name, :input_collection, :value_method, :text_method, :input_data

      def div_classes
        merge_classes('form-check', @div_classes)
      end
    end
  end
end
