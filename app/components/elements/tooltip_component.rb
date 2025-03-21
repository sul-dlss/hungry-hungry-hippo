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
  end
end
