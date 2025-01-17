# frozen_string_literal: true

module Elements
  # Component for a button that is a link
  class ButtonLinkComponent < ApplicationComponent
    def initialize(link:, label: nil, variant: :primary, classes: [], bordered: true, **options) # rubocop:disable Metrics/ParameterLists
      @link = link
      @label = label
      @variant = variant
      @options = options
      @classes = classes
      @bordered = bordered
      super()
    end

    attr_reader :link, :label

    def call
      link_to(link, class: ButtonSupport.classes(classes: @classes, variant: @variant, bordered: @bordered),
                    **@options) do
        label || content
      end
    end
  end
end
