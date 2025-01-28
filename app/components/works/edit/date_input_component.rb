# frozen_string_literal: true

module Works
  module Edit
    # Component for editing single dates
    class DateInputComponent < ApplicationComponent
      def initialize(form:, with_approximate: false, with_reset: true, reset_class: nil)
        @form = form
        @with_approximate = with_approximate
        @with_reset = with_reset
        @reset_class = reset_class || form.object_name.parameterize
        super()
      end

      attr_reader :form, :reset_class

      def with_reset?
        @with_reset
      end

      def with_approximate?
        @with_approximate
      end
    end
  end
end
