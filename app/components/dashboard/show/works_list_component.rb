# frozen_string_literal: true

module Dashboard
  module Show
    # Component for rendering a table on the work show page.
    class WorksListComponent < ApplicationComponent
      def initialize(label:, current_user:)
        @label = label
        @current_user = current_user
        super()
      end

      attr_reader :label, :current_user

      delegate :works, to: :current_user
    end
  end
end
