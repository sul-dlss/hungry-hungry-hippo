# frozen_string_literal: true

module Elements
  # It spins.
  class SpinnerComponent < ApplicationComponent
    def initialize(message: 'Loading...', message_classes: [], message_position: :right, hide_message: false, # rubocop:disable Metrics/ParameterLists
                   image_path: nil, variant: nil, classes: [],
                   height: nil, width: nil, speed: 0.75, data: {}, id: nil)
      @message = message
      @variant = variant
      @hide_message = hide_message
      @classes = classes
      @image_path = image_path # Optionally spin an image
      @height = height
      @width = width
      @message_classes = message_classes
      @speed = speed # In seconds, so a larger number is slower. The default (0.75) is the same as Bootstrap's default.
      @data = data
      @id = id
      @message_position = message_position # :bottom or :right
      super()
    end

    attr_reader :message, :image_path, :data, :id

    def spinner_classes
      merge_classes('spinner-border', variant_class, border_class, 'mx-2')
    end

    def message_classes
      merge_classes(@message_classes, @hide_message ? 'visually-hidden' : nil)
    end

    def classes
      merge_classes(@classes, 'd-flex', message_position_classes)
    end

    def spinner_style
      return unless @height && @width

      "height: #{@height}px; width: #{@width}px; --bs-spinner-animation-speed: #{@speed}s;"
    end

    private

    def message_position_classes
      case @message_position # rubocop:disable Style/HashLikeCase
      when :bottom
        'flex-column'
      when :right
        'align-items-center'
      when :top
        'flex-column-reverse'
      when :left
        'flex-row-reverse align-items-center justify-content-end'
      end
    end

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
