# frozen_string_literal: true

module Works
  module Show
    # Component for notifying the user that the work is being deposited.
    class DepositingComponent < ApplicationComponent
      def initialize(work_presenter:)
        @work_presenter = work_presenter
        super()
      end

      def render?
        @work_presenter.accessioning?
      end
    end
  end
end
