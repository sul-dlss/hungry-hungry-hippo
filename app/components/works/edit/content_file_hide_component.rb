# frozen_string_literal: true

module Works
  module Edit
    # Component for rendering the content file delete form
    class ContentFileHideComponent < ApplicationComponent
      def initialize(content_file:)
        @content_file = content_file
        super()
      end

      attr_reader :content_file

      def form_id
        dom_id(content_file, 'hide_form')
      end
    end
  end
end
