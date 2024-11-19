# frozen_string_literal: true

module Elements
  # Applies an h# component with the expected styling.
  class HeaderComponent < ApplicationComponent
    def initialize(variant, value:, classes: [])
      raise ArgumentError, 'Invalid variant' unless %w[h1 h2 h3 h4 h5 h6].include?(variant)

      @variant = variant
      @classes = classes
      @value = value
      super()
    end

    attr_reader :variant, :value

    def classes
      merge_classes(variant, @classes)
    end
  end
end
