# frozen_string_literal: true

module Elements
  # Component for rendering a table on the work show page.
  class TableComponent < ApplicationComponent
    renders_many :rows, 'Elements::TableRowComponent'

    def initialize(id:, classes:, headers:)
      @id = id
      @classes = classes
      @headers = headers
      super()
    end

    attr_reader :headers, :id

    def classes
      merge_classes(@classes)
    end
  end
end
