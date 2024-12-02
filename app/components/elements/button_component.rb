# frozen_string_literal: true

module Elements
  # Generic button component
  class ButtonComponent < ViewComponent::Base
    def initialize(label: nil, classes: [], variant: nil, size: nil, **options)
      @label = label
      @classes = classes
      @variant = variant
      @size = size
      @options = options
      super()
    end

    attr_reader :options, :label

    def call
      tag.button(
        class: ButtonSupport.classes(variant: @variant, size: @size, classes: @classes),
        type: 'button',
        **options
      ) do
        label || content
      end
    end
  end
end
