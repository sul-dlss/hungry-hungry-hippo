# frozen_string_literal: true

module Elements
  module Layout
    # Component for a tab in a tabbed pane.
    class TabComponent < ApplicationComponent
      def initialize(label:, tab_name:, selected: false)
        @label = label
        @tab_name = tab_name
        @selected = selected
        super()
      end

      def call
        tag.div(
          class: classes,
          id: "#{tab_name}-tab",
          data: { bs_toggle: 'tab', bs_target: "##{pane_id}", tab_error_target: 'tab' },
          type: 'button',
          'aria-controls': pane_id,
          'aria-selected': selected?
        ) do
          label
        end
      end

      attr_reader :label, :tab_name

      def selected?
        @selected
      end

      def classes
        merge_classes('nav-link my-1', selected? ? 'active' : nil)
      end

      def id
        "#{tab_name}-tab"
      end

      def pane_id
        "#{tab_name}-pane"
      end
    end
  end
end
