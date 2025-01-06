# frozen_string_literal: true

module Elements
  module Forms
    # Component for a form submit button
    class SubmitComponent < ApplicationComponent
      def initialize(form_id: nil, label: nil, variant: :primary, classes: [], **options)
        @form_id = form_id
        @label = label
        @variant = variant
        @options = options
        @classes = classes
        super()
      end

      attr_reader :form, :label

      def call
        submit_tag(label, form: @form_id, class: ButtonSupport.classes(variant: @variant, classes:), **@options)
      end

      def classes
        merge_classes(@classes)
      end
    end
  end
end
