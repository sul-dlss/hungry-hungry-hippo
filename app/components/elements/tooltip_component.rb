# frozen_string_literal: true

module Elements
  # Component for rendering a tooltip.
  class TooltipComponent < ApplicationComponent
    def initialize(target_label:, tooltip: nil)
      @target_label = target_label
      @tooltip = tooltip
      super()
    end

    private

    attr_reader :tooltip, :target_label

    def render?
      tooltip.present?
    end

    def data
      {
        bs_html: true,
        bs_toggle: 'tooltip',
        bs_title: tooltip,
        bs_trigger: 'focus',
        tooltips_target: 'icon'
      }.tap do |data|
        if Settings.ahoy.tooltip
          data[:controller] = 'ahoy-tooltip'
          data[:ahoy_tooltip_label_value] = target_label
          # Note that this is only tracking tooltip when shown by clicking, not when shown by focus.
          data[:action] = 'click->ahoy-tooltip#track'
        end
      end
    end
  end
end
