# frozen_string_literal: true

module Elements
  module Tables
    # Component for rendering an actions row in a treegrid table (e.g., expand/collapse all controls).
    class TreegridActionsRowComponent < ApplicationComponent
      def initialize(colspan: 1)
        @colspan = colspan
        super()
      end

      attr_reader :colspan
    end
  end
end
