# frozen_string_literal: true

module Works
  module Edit
    # Component for rendering the content file delete form
    class ContentFileDeleteComponent < ApplicationComponent
      def initialize(content_file:)
        @content_file = content_file
        super()
      end

      attr_reader :content_file

      def label
        'Remove this file'
      end

      def data
        {
          turbo_method: :delete,
          turbo_frame: dom_id(content_file.content, 'show'),
          action: 'unsaved-changes#changed'
        }
      end
    end
  end
end
