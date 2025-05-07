# frozen_string_literal: true

module Elements
  # Component for a button that is wrapped in a form
  class ButtonFormComponent < ApplicationComponent
    def initialize(link:, label: nil, variant: :primary, classes: [], method: :get, confirm: nil, # rubocop:disable Metrics/ParameterLists
                   top: true, data: {})
      @link = link
      @label = label
      @variant = variant
      @classes = classes
      @method = method
      @confirm = confirm
      @top = top
      @data = data
      super()
    end

    attr_reader :link

    def call
      button_to(link, method: @method,
                      class: ButtonSupport.classes(variant: @variant, classes:),
                      form: { data: }) do
        @label || content
      end
    end

    def classes
      merge_classes(@classes)
    end

    def data
      @data.tap do |data|
        data[:turbo_frame] = '_top' if @top
        data[:turbo_confirm] = @confirm if @confirm
      end
    end
  end
end
