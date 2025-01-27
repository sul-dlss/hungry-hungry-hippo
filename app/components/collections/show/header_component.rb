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

      def allowed_to_create_work?
        helpers.allowed_to?(:create_work?, presenter.collection)
      end
    end
  end
end
