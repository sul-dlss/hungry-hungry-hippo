# frozen_string_literal: true

module Elements
  module Forms
    # Component for a form submit button
    class SubmitComponent < ApplicationComponent
      def initialize(label: nil, value: nil, form_id: nil, variant: :primary, classes: [], **options) # rubocop:disable Metrics/ParameterLists
        # Either provide label OR value and content
        @form_id = form_id
        @label = label
        @variant = variant
        @options = options
        @classes = classes
        @value = value || label
        super()
      end

      attr_reader :form, :label, :options, :form_id, :value

      def classes
        ButtonSupport.classes(variant: @variant, classes: @classes)
      end
    end
  end
end
