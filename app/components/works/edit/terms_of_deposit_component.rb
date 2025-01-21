# frozen_string_literal: true

module Works
  module Edit
    # Component for rendering the terms of deposit form
    class TermsOfDepositComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super
      end

      attr_reader :form

      def already_agreed?
        form.object.agree_to_terms
      end
    end
  end
end
