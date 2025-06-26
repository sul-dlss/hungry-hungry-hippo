# frozen_string_literal: true

module Works
  module Show
    # Component for the "Manage sharing" button on the work show page.
    class ManageSharingButtonComponent < ApplicationComponent
      def initialize(work:)
        @work = work
        super()
      end

      def call
        render Elements::ButtonLinkComponent.new(link: new_work_share_path(work), label: 'Manage sharing',
                                                 variant: 'outline-primary')
      end

      def render?
        helpers.allowed_to?(:manage?, work, with: SharePolicy)
      end

      attr_reader :work
    end
  end
end
