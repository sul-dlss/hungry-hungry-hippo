# frozen_string_literal: true

module Emails
  module Works
    # Component for displaying a message about verifying contacts for a deposit.
    class VerifyContactsComponent < ApplicationComponent
      def call
        tag.p do
          'Please check the contact emails information on this item and if it is no longer current, ' \
          'update this field by clicking on the blue pencil icon next to the header "Title and contact."'.html_safe # rubocop:disable Rails/OutputSafety
        end
      end
    end
  end
end
