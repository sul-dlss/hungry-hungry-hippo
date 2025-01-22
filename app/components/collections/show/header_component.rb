# frozen_string_literal: true

module Collections
  module Show
    # Component for rendering a show page header.
    class HeaderComponent < ApplicationComponent
      def initialize(presenter:)
        @presenter = presenter
        super()
      end
      attr_reader :presenter

      delegate :title, :status_message, to: :presenter
    end
  end
end
