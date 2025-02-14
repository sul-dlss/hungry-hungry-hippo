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

      attr_reader :tab_name, :selected, :label, :help_text

      def classes
        merge_classes(%w[tab-pane fade h-100], selected ? 'show active' : nil)
      end

      def tooltip?
        tooltip.present?
      end

      def tooltip
        # The tooltip can include a trailing \n that isn't rendered in the HTML but does make for ugly source markup
        @tooltip&.chomp
      end

      def tooltip_template
        <<~HTML.squish
          <div class="tooltip tooltip-shift-right" role="tooltip">
            <div class="tooltip-arrow"></div>
            <div class="tooltip-inner text-start"></div>
          </div>
        HTML
      end

      def tooltip_data
        {
          bs_html: true,
          bs_template: tooltip_template,
          bs_toggle: 'tooltip',
          bs_title: tooltip,
          bs_trigger: 'click focus',
          tooltips_target: 'icon'
        }
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
