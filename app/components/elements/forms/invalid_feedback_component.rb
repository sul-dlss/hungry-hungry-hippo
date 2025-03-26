# frozen_string_literal: true

module Elements
  module Forms
    # Component for rendering invalid feedback for a form field.
    class InvalidFeedbackComponent < ApplicationComponent
      def initialize(field_name:, form:, classes: [], data: {})
        @field_name = field_name
        @form = form
        @classes = classes
        @data = data
        super()
      end

      attr_reader :field_name, :form, :data

      def call
        tag.div(class: classes, id:, data:) do
          errors.join(', ')
        end
      end

      def render?
        field_name.present? && errors.present?
      end

      private

      def id
        InvalidFeedbackSupport.id_for(field_name:, form:)
      end

      def errors
        @errors ||= form.object&.errors&.[](field_name)
      end

      def classes
        # Adding is-invalid to trigger the tab error.
        merge_classes(%w[invalid-feedback is-invalid d-block], @classes)
      end
    end
  end
end
