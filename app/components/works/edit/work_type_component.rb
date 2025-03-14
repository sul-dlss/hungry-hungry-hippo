# frozen_string_literal: true

module Works
  module Edit
    # Component for the work type and work subtypes fields
    class WorkTypeComponent < ApplicationComponent
      def initialize(form:, collection:)
        @form = form
        @collection = collection
        super()
      end

      attr_reader :form

      def label
        t('works.edit.fields.work_subtypes.label')
      end

      def tooltip
        t('works.edit.fields.work_subtypes.tooltip_html')
      end

      def work_type
        form.object.work_type
      end

      def readonly?
        @collection.work_type.present? && work_type == @collection.work_type
      end

      def required_subtypes
        @collection.work_subtypes
      end
    end
  end
end
