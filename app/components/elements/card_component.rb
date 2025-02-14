# frozen_string_literal: true

module Elements
  # Component for a card
  class CardComponent < ApplicationComponent
    renders_one :body, lambda { |**args|
      SectionComponent.new(default_class: 'card-body', **args)
    }
    renders_one :header, lambda { |**args|
      SectionComponent.new(default_class: 'card-header', **args)
    }

    def initialize(classes: [], style: nil, data: {})
      @classes = classes
      @style = style
      @data = data
      super()
    end

    def classes
      merge_classes('card', @classes)
    end

    attr_reader :style, :data

    # Component for a card section
    class SectionComponent < ApplicationComponent
      def initialize(default_class:, classes: [], style: nil, data: {})
        @classes = classes
        @default_class = default_class
        @style = style
        @data = data
        super()
      end

      def classes
        merge_classes(@default_class, @classes)
      end

      def call
        tag.div(class: classes, style: @style, data: @data) do
          content
        end
      end
    end
  end
end
