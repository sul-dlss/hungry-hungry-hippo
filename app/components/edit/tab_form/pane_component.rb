# frozen_string_literal: true

module Edit
  module TabForm
    # Component for a tab pane.
    # Based on https://getbootstrap.com/docs/5.3/components/navs-tabs/#javascript-behavior
    class PaneComponent < ApplicationComponent
      renders_one :footer
      renders_one :help

      def initialize(tab_name:, label: nil, selected: false, help_text: nil, tooltip: nil)
        @tab_name = tab_name
        @label = label
        @selected = selected
        @help_text = help_text
        @tooltip = tooltip
        super()
      end

      attr_reader :tab_name, :selected, :label, :help_text, :tooltip

      def classes
        merge_classes(%w[tab-pane fade h-100], selected ? 'show active' : nil)
      end

      def id
        "#{tab_name}-pane"
      end

      def tab_id
        "#{tab_name}-tab"
      end
    end
  end
end
