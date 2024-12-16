# frozen_string_literal: true

module Works
  module Edit
    # Component for rendering the content file description
    class ContentFileDescriptionComponent < ApplicationComponent
      def initialize(content_file:)
        @content_file = content_file
        super()
      end

      attr_reader :content_file
    end
  end
end
