# frozen_string_literal: true

module Collections
  module Edit
    # Component for the work type and work subtypes fields
    class WorkTypeComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super()
      end

      attr_reader :form

      def label
        t('collections.edit.fields.work_subtypes.label')
      end

      def tooltip
        t('collections.edit.fields.work_subtypes.tooltip_html')
      end

      def input_collection
        [WorkType.new(label: 'No required work type', subtypes: [],
                      cocina_type: Cocina::Models::ObjectType.object, value: '')] +
          WorkType.all.filter { |work_type| work_type.label != 'Other' }
      end
    end
  end
end
