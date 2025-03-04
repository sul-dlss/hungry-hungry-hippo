# frozen_string_literal: true

module Elements
  # Component for rendering a tooltip.
  class TooltipComponent < ApplicationComponent
    def initialize(tooltip: nil)
      @tooltip = tooltip
      super()
    end

    def call
      helpers.info_icon(
        fill: true,
        classes: 'px-2 tooltip-info',
        tabindex: 0,
        data: {
          bs_html: true,
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
  end
end
