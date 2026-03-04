# frozen_string_literal: true

module Elements
  module Forms
    # Component for rendering invalid feedback for a form field.
    class InvalidFeedbackComponent < ApplicationComponent
      def initialize(field_name:, form:, classes: [], data: {}, except: [])
        @field_name = field_name
        @form = form
        @classes = classes
        @data = data
        @except = except
        super()
      end

      attr_reader :field_name, :form, :data, :except

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
        @errors ||= Array(form.object&.errors&.where(field_name)).reject do |error|
          except.include?(error.type)
        end.map(&:message)
      end

      def classes
        # Adding is-invalid to trigger the tab error.
        merge_classes(%w[invalid-feedback is-invalid d-block], @classes)
      end
    end
  end
end
