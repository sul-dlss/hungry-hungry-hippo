# frozen_string_literal: true

module Elements
  # Component for a delete button
  class DeleteButtonComponent < ApplicationComponent
    def initialize(classes: [], data: {})
      @classes = classes
      @data = data
      super()
    end

    attr_reader :data

    def classes
      merge_classes(%w[border border-0], @classes)
    end
  end
end
