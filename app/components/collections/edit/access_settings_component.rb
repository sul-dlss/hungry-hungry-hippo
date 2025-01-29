# frozen_string_literal: true

module Collections
  module Edit
    # Component for rendering the access settings pane.
    class AccessSettingsComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super()
      end

      attr_reader :form

      def release_duration_options
        Collection::RELEASE_DURATION_OPTIONS
      end
    end
  end
end
