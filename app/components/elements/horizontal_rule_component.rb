# frozen_string_literal: true

module Elements
  # Component for a horizontal rule (line).
  class HorizontalRuleComponent < ApplicationComponent
    def initialize(classes: [])
      @classes = classes
      super()
    end

    def call
      tag.hr class: classes
    end

    def classes
      merge_classes(@classes)
    end
  end
end
