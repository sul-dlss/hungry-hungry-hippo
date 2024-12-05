# frozen_string_literal: true

module Dashboard
  module Show
    # Component for rendering collection titles and collection works.
    class CollectionsListComponent < ApplicationComponent
      def initialize(label:, collections:, status_map:)
        @label = label
        @collections = collections
        @status_map = status_map
        super()
      end

      attr_reader :label, :collections, :status_map
    end
  end
end
