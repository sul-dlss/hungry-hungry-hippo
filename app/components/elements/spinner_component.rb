# frozen_string_literal: true

module Elements
  # It spins.
  class SpinnerComponent < ApplicationComponent
    def initialize(message: 'Loading...', image_path: nil, variant: nil, hide_message: false, classes: [], # rubocop:disable Metrics/ParameterLists
                   height: nil, width: nil, message_classes: [], speed: 0.75)
      @message = message
      @variant = variant
      @hide_message = hide_message
      @classes = classes
      @image_path = image_path # Optionally spin an image
      @height = height
      @width = width
      @message_classes = message_classes
      @speed = speed # In seconds, so a larger number is slower. The default (0.75) is the same as Bootstrap's default.
      super()
    end

    attr_reader :message, :image_path

    def spinner_classes
      merge_classes('spinner-border', variant_class, border_class)
    end

    def message_classes
      merge_classes(@message_classes, @hide_message ? 'visually-hidden' : nil)
    end

    def classes
      merge_classes(@classes)
    end

    def spinner_style
      return unless @height && @width

      "height: #{@height}px; width: #{@width}px; --bs-spinner-animation-speed: #{@speed}s;"
    end

    private

    def variant_class
      return unless @variant

      "text-#{@variant}"
    end

    def border_class
      return unless image_path

      'border-0'
    end
  end
end
