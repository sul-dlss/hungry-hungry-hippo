# frozen_string_literal: true

module Elements
  # Component for a button that is a link
  class ButtonLinkComponent < ApplicationComponent
    def initialize(link:, label: nil, variant: :primary, classes: [], **options)
      @link = link
      @label = label
      @variant = variant
      @options = options
      @classes = classes
      super()
    end

    attr_reader :link, :label

    def call
      link_to(link, class: ButtonSupport.classes(variant: @variant, classes:), **@options) do
        label || content
      end
    end

    def classes
      merge_classes(@classes)
    end
  end
end
