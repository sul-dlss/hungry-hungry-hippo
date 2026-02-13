# frozen_string_literal: true

module Works
  module Edit
    # Comoponent for the title pane on the edit form.
    class TitleComponent < ApplicationComponent
      def initialize(form:, work_form:)
        @form = form
        @work_form = work_form
        super()
      end

      attr_reader :form, :work_form

      delegate :works_contact_email, to: :work_form
    end
  end
end
