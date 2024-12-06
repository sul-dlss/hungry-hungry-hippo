# frozen_string_literal: true

module Works
  module Edit
    # Component for the work type and work subtypes fields
    class WorkTypeComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super()
      end

      attr_reader :form
    end
  end
end
