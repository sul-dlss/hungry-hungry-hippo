# frozen_string_literal: true

module Collections
  module Edit
    # Component for rendering a tab pane for a collection edit form.
    class PaneComponent < ApplicationComponent
      renders_one :deposit_button # If not provided will render Next button

      def initialize(**pane_args)
        @pane_args = pane_args
        super()
      end

      attr_reader :pane_args

      def tab_id
        "#{pane_args[:tab_name]}-tab"
      end
    end
  end
end
