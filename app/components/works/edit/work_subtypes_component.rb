# frozen_string_literal: true

module Works
  module Edit
    # Component for the work subtypes field
    class WorkSubtypesComponent < ApplicationComponent
      def initialize(form:, work_type:, label:, tooltip: nil, more_options: false, minimum_terms: 0, # rubocop:disable Metrics/ParameterLists
                     error_field_name: nil, required_subtypes: [])
        @form = form
        @work_type = work_type
        @label = label
        @more_options = more_options
        @minimum_terms = minimum_terms
        @error_field_name = error_field_name
        @tooltip = tooltip
        @required_subtypes = required_subtypes
        super()
      end

      attr_reader :form, :work_type, :minimum_terms, :error_field_name, :label, :tooltip, :required_subtypes

      def more_options?
        @more_options
      end

      def data
        {
          work_type_target: 'subtypeSection',
          work_type:
        }
      end

      def work_subtypes
        @work_subtypes ||= WorkType.subtypes_for(work_type)
      end

      def more_types
        WorkType.more_types - work_subtypes - [work_type]
      end

      def collapse_id
        "more-options-#{work_type.parameterize}"
      end

      def term_phrase
        case minimum_terms
        when 2
          'two terms'
        when 1
          'one term'
        else
          raise ArgumentError, "minimum_terms must be 1 or 2, not #{minimum_terms}"
        end
      end

      def fieldset_aria
        Elements::Forms::InvalidFeedbackSupport.arias_for(form:, field_name: error_field_name)
      end
    end
  end
end
