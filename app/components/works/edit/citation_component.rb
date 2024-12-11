# frozen_string_literal: true

module Works
  module Edit
    # Component for the work citation field
    class CitationComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super()
      end

      attr_reader :form
    end
  end
end
