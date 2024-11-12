# frozen_string_literal: true

module Elements
  module Forms
    # Component for a form submit button
    class SubmitComponent < ApplicationComponent
      def initialize(form:, label: nil, variant: :primary, classes: [], **options)
        @form = form
        @label = label
        @variant = variant
        @options = options
        @classes = classes
        super()
      end

      attr_reader :form, :label

      def call
        form.submit(label, class: Elements::ButtonSupport.classes(variant: @variant, classes:), **@options)
      end

      def classes
        merge_classes(@classes)
      end
    end
  end
end
