# frozen_string_literal: true

module Elements
  # Component for rendering a table row on the work show page.
  class TableBodyComponent < ApplicationComponent
    def initialize(classes: nil, rows: nil)
      # If value is not provided, content block will be rendered instead.
      @classes = classes
      @rows = rows
      super()
    end

    attr_reader :classes, :rows
  end
end
