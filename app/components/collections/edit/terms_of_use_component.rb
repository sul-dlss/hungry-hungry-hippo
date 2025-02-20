# frozen_string_literal: true

module Collections
  module Edit
    # Select field for license
    class TermsOfUseComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super()
      end

      attr_reader :form
    end
  end
end
