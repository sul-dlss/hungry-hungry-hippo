# frozen_string_literal: true

module Edit
  module TabForm
    # Component for a tab in a tabbed pane.
    class TabComponent < ApplicationComponent
      def initialize(label:, tab_name:, active_tab_name:, mark_required: false)
        @label = label
        @tab_name = tab_name
        @selected = tab_name == active_tab_name
        @mark_required = mark_required
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

      attr_reader :tab_name

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

      def mark_required?
        @mark_required
      end

      def label
        @label.dup.tap do |label_text|
          label_text << ' (optional)' unless mark_required?
        end
      end
    end
  end
end
