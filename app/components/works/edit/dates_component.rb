# frozen_string_literal: true

module Works
  module Edit
    # Component for rendering dates pane form.
    class DatesComponent < ApplicationComponent
      def initialize(form:, with_create_date: true)
        @form = form
        @with_create_date = with_create_date
        super()
      end

      attr_reader :form

      def create_date_range_from_error?
        form.object.errors[:create_date_range_from].any?
      end

      def with_create_date?
        @with_create_date
      end
    end
  end
end
