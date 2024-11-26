# frozen_string_literal: true

module Elements
  module Layout
    # Component for the tabbed form.
    class FormComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super()
      end
    end
  end
end
