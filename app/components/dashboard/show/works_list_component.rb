# frozen_string_literal: true

module Dashboard
  module Show
    # Component for rendering a table on the work show page.
    class WorksListComponent < ApplicationComponent
      def initialize(label:, works:)
        @label = label
        @works = works
        super()
      end

      attr_reader :label, :works
    end
  end
end
