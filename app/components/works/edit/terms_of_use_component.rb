# frozen_string_literal: true

module Works
  module Edit
    # Component for rendering the terms of use form
    class TermsOfUseComponent < ApplicationComponent
      def initialize(form:, collection:)
        @form = form
        @collection = collection
        super
      end

      attr_reader :form

      delegate :provided_custom_rights_statement_option?, :provided_custom_rights_statement,
               :custom_rights_statement_custom_instructions, to: :@collection

      def instructions
        custom_rights_statement_custom_instructions.presence || default_instructions
      end

      private

      def default_instructions
        'Enter additional terms of use not covered by your chosen license or the default terms shown above, ' \
          'which also displays on the PURL page.'
      end

      def label
        'Additional terms of use'
      end
    end
  end
end
