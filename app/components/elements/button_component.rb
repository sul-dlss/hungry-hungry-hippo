# frozen_string_literal: true

module Elements
  # Generic button component
  class ButtonComponent < ViewComponent::Base
    def initialize(label: nil, classes: [], variant: nil, size: nil, bordered: true, **options) # rubocop:disable Metrics/ParameterLists
      @label = label
      @classes = classes
      @variant = variant
      @size = size
      @options = options
      @bordered = bordered
      super()
    end

    attr_reader :options, :label

    def call
      tag.button(
        class: ButtonSupport.classes(variant: @variant, size: @size, classes: @classes, bordered: @bordered),
        type: 'button',
        **options
      ) do
        label || content
      end
    end
  end
end
