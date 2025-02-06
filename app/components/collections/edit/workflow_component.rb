# frozen_string_literal: true

module Collections
  module Edit
    # Component for rendering the review workflow pane.
    class WorkflowComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super()
      end

      attr_reader :form
    end
  end
end
