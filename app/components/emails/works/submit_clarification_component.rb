# frozen_string_literal: true

module Emails
  module Works
    # Component for displaying clarificatory text for a work submission.
    class SubmitClarificationComponent < ApplicationComponent
      def call
        tag.p do
          'If you did not recently submit your item for review, the submission was made by your ' \
            'collection manager or an SDR admin.'
        end
      end
    end
  end
end
