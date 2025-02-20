# frozen_string_literal: true

module Works
  module Edit
    # Component for editing work contact emails
    class ContactEmailsComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super()
      end

      attr_reader :form
    end
  end
end
