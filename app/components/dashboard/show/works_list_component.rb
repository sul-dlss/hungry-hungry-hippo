# frozen_string_literal: true

module Dashboard
  module Show
    # Component for rendering a table on the work show page.
    class WorksListComponent < ApplicationComponent
      def initialize(collection:)
        @collection = collection
        super()
      end

      attr_reader :collection

      delegate :works, to: :collection
    end
  end
end
