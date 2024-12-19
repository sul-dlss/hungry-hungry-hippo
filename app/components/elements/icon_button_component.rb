# frozen_string_literal: true

module Elements
  # Component for a button which is an icon
  class IconButtonComponent < ApplicationComponent
    def initialize(icon:, label:, classes: [], data: {})
      @icon = icon
      @label = label
      @classes = classes
      @data = data
      super()
    end

    attr_reader :data, :label

    def classes
      merge_classes(%w[border border-0], @classes)
    end

    def button_icon
      helpers.public_send(:"#{@icon}_icon")
    end
  end
end
