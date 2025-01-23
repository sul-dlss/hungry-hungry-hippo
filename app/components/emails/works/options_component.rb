# frozen_string_literal: true

module Emails
  module Works
    # Component for displaying options for a work.
    class OptionsComponent < ApplicationComponent
      def initialize(work_presenter:)
        @work_presenter = work_presenter
        super()
      end

      delegate :license_label, :access_label, :release_date_label, to: :@work_presenter
    end
  end
end
