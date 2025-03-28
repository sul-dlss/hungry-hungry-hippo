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
               :custom_rights_statement_instructions, to: :@collection

      private

      def label
        helpers.t('works.edit.fields.custom_rights_statement.label')
      end

      def tooltip
        helpers.t('works.edit.fields.custom_rights_statement.tooltip_html')
      end
    end
  end
end
