# frozen_string_literal: true

module Works
  module Show
    # Component for rendering a file hierarchy row for a ContentFile.
    class ContentHierarchyComponent < ApplicationComponent
      # NOTE: content is a reserved word in a view component, so using content_obj instead.
      def initialize(content_obj:, work_presenter:)
        @content_obj = content_obj
        @work_presenter = work_presenter
        super()
      end

      def content_files
        @content_obj.content_files.path_order
      end

      # show the expand/collapse control if there is a file hiearchy and more than 3 files
      def show_expand_collapse?
        content_files.size > 3 && content_files.any?(&:hierarchy?)
      end

      attr_reader :work_presenter
    end
  end
end
