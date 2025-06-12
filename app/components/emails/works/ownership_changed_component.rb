# frozen_string_literal: true

module Emails
  module Works
    # Component for displaying a message about ownership changes for a deposit.
    class OwnershipChangedComponent < ApplicationComponent
      def initialize(work:)
        @work = work
        super()
      end

      attr_reader :work

      def call
        tag.p do
          "You are now the owner of the item \"#{link_to_work}\" in the Stanford Digital Repository " \
          'and have access to manage its metadata and files. ' \
          "Click #{link_to_work} to view or edit this item.".html_safe # rubocop:disable Rails/OutputSafety
        end
      end

      def link_to_work
        link_to work_url(work), work_url(work)
      end
    end
  end
end
