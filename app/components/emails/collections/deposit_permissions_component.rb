# frozen_string_literal: true

module Emails
  module Collections
    # Component for displaying a message about a DOI being assigned to a work.
    class DepositPermissionsComponent < ApplicationComponent
      def initialize(collection:)
        @collection = collection
        super()
      end

      def call
        tag.p do
          "You now also have permission to deposit items into the #{@collection.title} collection.".html_safe # rubocop:disable Rails/OutputSafety
        end
      end
    end
  end
end
