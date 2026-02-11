# frozen_string_literal: true

module Edit
  module TabForm
    # Component for a tab in a tabbed pane.
    class TabComponent < ApplicationComponent
      def initialize(label:, tab_name:, active_tab_name:, render: true)
        @label = label
        @tab_name = tab_name
        @selected = tab_name == active_tab_name
        @render = render
        super()
      end

      def call
        tag.button(
          class: classes,
          id:,
          data: {
            bs_toggle: 'tab',
            bs_target: "##{pane_id}",
            tab_error_target: 'tab',
            action: 'click->tooltips#hideAll'
          },
          type: 'button',
          'aria-controls': pane_id,
          'aria-selected': selected?,
          'aria-labelledby': id,
          'aria-role': 'tab',
          tabindex: '0',
          role: 'tab'
        ) do
          label
        end
      end

      attr_reader :label, :tab_name

      def selected?
        @selected
      end

      def classes
        merge_classes('nav-link w-100', selected? ? 'active' : nil)
      end

      def id
        "#{tab_name}-tab"
      end

      def pane_id
        "#{tab_name}-pane"
      end

      def render?
        @render
      end
    end
  end
end
