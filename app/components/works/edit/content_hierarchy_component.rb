# frozen_string_literal: true

module Works
  module Edit
    # Component for rendering an editable file hierarchy table for a Content.
    class ContentHierarchyComponent < ApplicationComponent
      def initialize(content_files:)
        @content_files = content_files
        super()
      end

      attr_reader :content_files

      # show the expand/collapse control if there is a file hiearchy and more than 3 files
      def show_expand_collapse?
        content_files.size > 3 && content_files.any?(&:hierarchy?)
      end
    end
  end
end
