# frozen_string_literal: true

module Elements
  module Forms
    # Component for rendering invalid feedback for a form field.
    class InvalidFeedbackComponent < ApplicationComponent
      def initialize(field_name:, form:, render_errors: true, classes: [])
        @field_name = field_name
        @form = form
        @classes = classes
        @render_errors = render_errors
        super()
      end

      attr_reader :field_name, :form

      def call
        tag.div(class: classes) do
          errors.join(', ')
        end
      end

      def render?
        field_name.present? && errors.present? && @render_errors
      end

      private

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
