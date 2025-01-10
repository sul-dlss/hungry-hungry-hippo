# frozen_string_literal: true

module Works
  module Edit
    # Component for rendering the access settings pane.
    class AccessSettingsComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super()
      end
    end
  end
end
