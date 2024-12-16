# frozen_string_literal: true

module Works
  module Edit
    # Component for rendering an editable file hierarchy table for a Content.
    class ContentHierarchyComponent < ApplicationComponent
      # NOTE: content is a reserved word in a view component, so using content_obj instead.
      def initialize(content_obj:)
        @content_obj = content_obj
        super()
      end

      def content_files
        @content_obj.content_files.path_order
      end
    end
  end
end
