# frozen_string_literal: true

module Collections
  module Edit
    # Component for rendering the participant notification options.
    class ParticipantNotificationsComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super()
      end

      attr_reader :form
    end
  end
end
