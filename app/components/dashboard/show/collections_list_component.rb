# frozen_string_literal: true

module Dashboard
  module Show
    # Component for rendering collection titles and collection works for the current user.
    class CollectionsListComponent < ApplicationComponent
      def initialize(label:, current_user:)
        @label = label
        @current_user = current_user
        super()
      end

      attr_reader :label, :current_user

      delegate :collections, to: :current_user
    end
  end
end
