# frozen_string_literal: true

module Elements
  # Component for a button which is an icon
  class IconButtonLinkComponent < ApplicationComponent
    def initialize(icon:, label:, classes: [], icon_classes: [], data: {}, link: nil) # rubocop:disable Metrics/ParameterLists
      @icon = icon
      @label = label
      @classes = classes
      @data = data
      @link = link
      @icon_classes = icon_classes
      super()
    end

    attr_reader :data, :label

    def classes
      merge_classes(%w[border border-0], @classes)
    end

    def button_icon
      helpers.public_send(:"#{@icon}_icon", classes: @icon_classes)
    end
  end
end
