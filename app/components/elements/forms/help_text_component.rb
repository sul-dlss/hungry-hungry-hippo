# frozen_string_literal: true

# Component for rendering help text for form fields.
module Elements
  module Forms
    # Component for rendering help text for form fields.
    class HelpTextComponent < ApplicationComponent
      def initialize(help_text:, id:)
        @help_text = help_text
        @id = id
        super()
      end

      attr_reader :help_text, :id

      def render?
        help_text.present?
      end
    end
  end
end
