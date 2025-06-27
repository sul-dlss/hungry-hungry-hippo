# frozen_string_literal: true

# Component for rendering help text for form fields.
module Elements
  module Forms
    # Component for rendering help text for form fields.
    class HelpTextComponent < ApplicationComponent
      # this component can take plain text via 'help_text' or a block (which can contain html)
      # it will render the help_text if provided, else it will render the block content
      def initialize(id:, help_text: nil)
        @help_text = help_text
        @id = id
        super()
      end

      attr_reader :help_text, :id

      def render?
        help_text.present? || content.present?
      end
    end
  end
end
