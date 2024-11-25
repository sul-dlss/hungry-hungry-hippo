# frozen_string_literal: true

module Elements
  # Wait for it.
  class ProgressBarComponent < ApplicationComponent
    def initialize(label:, percent: 0, variant: nil, classes: [], striped: true, data: {}) # rubocop:disable Metrics/ParameterLists
      @label = label
      @percent = percent
      @variant = variant
      @classes = classes
      @striped = striped
      @data = data
      super()
    end

    attr_reader :label, :percent, :data

    def bar_classes
      merge_classes('progress-bar', variant_class, @striped ? 'progress-bar-striped' : nil)
    end

    def bar_style
      "width: #{percent}%;"
    end

    def classes
      merge_classes('progress', @classes)
    end

    private

    def variant_class
      return unless @variant

      "bg-#{@variant}"
    end
  end
end
