# frozen_string_literal: true

module Elements
  # Component for rendering a table row on the work show page.
  class TableHeaderComponent < ApplicationComponent
    def initialize(classes:, headers: nil)
      # If value is not provided, content block will be rendered instead.
      @classes = classes
      @headers = headers
      super()
    end

    attr_reader :classes, :headers
  end
end
