# frozen_string_literal: true

module Collections
  module Edit
    # Component for editing collection contact emails
    class ContactEmailsComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super()
      end

      attr_reader :form
    end
  end
end
