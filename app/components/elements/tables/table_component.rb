# frozen_string_literal: true

module Elements
  module Tables
    # Component for rendering a table.
    class TableComponent < BaseTableComponent
      renders_many :rows, Elements::Tables::RowComponent
    end
  end
end
