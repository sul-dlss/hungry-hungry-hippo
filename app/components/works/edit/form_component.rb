# frozen_string_literal: true

module Works
  module Edit
    # Component for the Work edit form.
    class FormComponent < ApplicationComponent
      def initialize(work_form:, files:)
        @work_form = work_form
        @files = files
        super()
      end
    end
  end
end
