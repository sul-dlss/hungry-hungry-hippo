# frozen_string_literal: true

module Works
  module Edit
    # Component for rendering an editable file flat table for a Content.
    class ContentNonHierarchyComponent < ApplicationComponent
      # NOTE: content is a reserved word in a view component, so using content_obj instead.
      def initialize(content_obj:, content_files:)
        @content_files = content_files
        @content_obj = content_obj
        super()
      end

      attr_reader :content_files, :content_obj
    end
  end
end
