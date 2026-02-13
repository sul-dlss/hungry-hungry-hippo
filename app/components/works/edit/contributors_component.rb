# frozen_string_literal: true

module Works
  module Edit
    # Component for the contributors pane on the edit form.
    class ContributorsComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super()
      end

      attr_reader :form
    end
  end
end
