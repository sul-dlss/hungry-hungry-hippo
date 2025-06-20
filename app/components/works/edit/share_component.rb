# frozen_string_literal: true

module Works
  module Edit
    # Component for editing work shares
    class ShareComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super()
      end

      attr_reader :form

      delegate :sunetid, :name, to: :object

      delegate :object, to: :form

      def value
        return unless sunetid

        "#{sunetid}: #{name}"
      end

      def aria_label
        "Set sharing permissions for #{name}"
      end

      def options
        [
          ['View only', Share::VIEW_PERMISSION],
          ['View and edit', Share::VIEW_EDIT_PERMISSION],
          ['View, edit, and deposit', Share::VIEW_EDIT_DEPOSIT_PERMISSION]
        ]
      end
    end
  end
end
