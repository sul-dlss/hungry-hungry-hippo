# frozen_string_literal: true

module Elements
  # Component for rendering a table on the work show page.
  class TableComponent < ApplicationComponent
    renders_many :rows, 'Elements::TableRowComponent'

    def initialize(id:, classes:, label: nil, header_classes: nil, headers: nil)
      @id = id
      @classes = classes
      @label = label
      @header_classes = header_classes
      @headers = headers
      super()
    end

    attr_reader :label, :header_classes, :headers, :id

    def classes
      merge_classes(@classes)
    end
  end
end
