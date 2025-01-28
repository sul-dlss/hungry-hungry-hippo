# frozen_string_literal: true

module Works
  module Edit
    # Component for rendering dates pane form.
    class DatesComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super()
      end

      attr_reader :form

      def create_date_range_from_error?
        form.object.errors[:create_date_range_from].any?
      end
    end
  end
end
