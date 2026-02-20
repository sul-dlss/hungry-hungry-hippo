# frozen_string_literal: true

module Articles
  module Edit
    # Component for rendering the Terms of Deposit checkbox and modal
    class TermsOfDepositComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super()
      end

      attr_reader :form

      def agree_to_terms?
        form.object.agree_to_terms
      end

      def label_text
        "I agree to the #{helpers.terms_of_deposit_modal_link}".html_safe # rubocop:disable Rails/OutputSafety
      end
    end
  end
end
