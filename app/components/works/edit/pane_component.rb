# frozen_string_literal: true

module Works
  module Edit
    # Component for a tab pane.
    # Based on https://getbootstrap.com/docs/5.3/components/navs-tabs/#javascript-behavior
    # rubocop:disable Metrics/ParameterLists
    class PaneComponent < ApplicationComponent
      def initialize(tab_name:, label:, form:, next_tab_name: nil, selected: false, render_footer: true)
        @tab_name = tab_name
        @label = label
        @selected = selected
        @form = form
        @next_tab_name = next_tab_name
        @render_footer = render_footer
        super()
      end

      attr_reader :tab_name, :next_tab_name, :selected, :label, :form

      def classes
        merge_classes(%w[tab-pane fade h-100], selected ? 'show active' : nil)
      end

      def id
        "#{tab_name}-pane"
      end

      def tab_id
        "#{tab_name}-tab"
      end

      def next_tab_id
        "#{next_tab_name}-tab"
      end

      def render_footer?
        @render_footer
      end
    end
    # rubocop:enable Metrics/ParameterLists
  end
end
