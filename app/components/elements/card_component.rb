# frozen_string_literal: true

module Elements
  # Component for a card
  class CardComponent < ApplicationComponent
    renders_one :body, 'BodyComponent'

    def initialize(classes: [], style: nil)
      @classes = classes
      @style = style
      super()
    end

    def classes
      merge_classes('card', @classes)
    end

    attr_reader :style

    # Component for a card body
    class BodyComponent < ApplicationComponent
      def initialize(classes: [], style: nil)
        @classes = classes
        @style = style
        super()
      end

      def classes
        merge_classes('card-body', @classes)
      end

      def call
        tag.div(class: classes, style: @style) do
          content
        end
      end
    end
  end
end
