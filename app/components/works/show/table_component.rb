# frozen_string_literal: true

module Works
  module Show
    # Component for rendering a table on the work show page.
    class TableComponent < ApplicationComponent
      renders_many :rows, 'Works::Show::TableRowComponent'

      def initialize(label:, id:)
        @label = label
        @id = id
        super()
      end

      attr_reader :label, :id
    end
  end
end
