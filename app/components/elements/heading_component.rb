# frozen_string_literal: true

module Elements
  # Applies an h# component with the expected styling.
  class HeadingComponent < ApplicationComponent
    def initialize(level:, text: nil, variant: nil, classes: [])
      raise ArgumentError, 'Invalid level' unless %i[h1 h2 h3 h4 h5 h6].include?(level.to_sym)

      @level = level
      @variant = variant
      @classes = classes
      @text = text # Provide text or content
      super()
    end

    def classes
      merge_classes(variant_class, @classes)
    end

    # Renders the component without the need for a .erb partial.
    def call
      content_tag(@level, class: classes) do
        @text || content
      end
    end

    private

    def variant_class
      return unless @variant

      @variant.to_s
    end
  end
end
