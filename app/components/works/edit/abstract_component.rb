# frozen_string_literal: true

module Works
  module Edit
    # Component for the abstract pane on the edit form.
    class AbstractComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super()
      end

      attr_reader :form
    end
  end
end
