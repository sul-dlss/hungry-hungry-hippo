# frozen_string_literal: true

module Emails
  module Works
    # Component for displaying a message about making changes to a deposit.
    class ChangesComponent < ApplicationComponent
      def call
        tag.p do
          "If you need to make changes to your deposit, you can do so at #{link_to nil, root_url}.".html_safe # rubocop:disable Rails/OutputSafety
        end
      end
    end
  end
end
