# frozen_string_literal: true

module Elements
  # Component for rendering a table row on the work show page.
  class TableRowComponent < ApplicationComponent
    def initialize(values: nil)
      # If value is not provided, content block will be rendered instead.
      @values = values
      super()
    end

    attr_reader :values
  end
end
