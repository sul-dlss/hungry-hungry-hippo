# frozen_string_literal: true

module Elements
  # Component for rendering a tooltip.
  class TooltipComponent < ApplicationComponent
    def initialize(tooltip: nil)
      # The tooltip can include a trailing \n that isn't rendered in the HTML but does make for ugly source markup
      @tooltip = tooltip&.chomp
      super()
    end

    def call
      helpers.info_icon(
        fill: true,
        classes: 'px-2 tooltip-info',
        data: {
          bs_html: true,
          bs_template: tooltip_template,
          bs_toggle: 'tooltip',
          bs_title: tooltip,
          bs_trigger: 'click focus',
          tooltips_target: 'icon'
        }
      )
    end

    private

    attr_reader :tooltip

    def render?
      tooltip.present?
    end

    def tooltip_template
      <<~HTML.squish
        <div class="tooltip tooltip-shift-right" role="tooltip">
          <div class="tooltip-arrow"></div>
          <div class="tooltip-inner text-start"></div>
        </div>
      HTML
    end
  end
end
