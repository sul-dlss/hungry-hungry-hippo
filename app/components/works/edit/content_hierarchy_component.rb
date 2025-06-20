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
    end
  end
end
