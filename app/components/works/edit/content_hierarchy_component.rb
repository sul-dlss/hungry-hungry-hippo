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

      def headers
        [
          TableHeader.new(label: 'File Name'),
          TableHeader.new(label: 'Description',
                          tooltip: helpers.t('content_files.edit.fields.description.tooltip_html')),
          TableHeader.new(label: 'Hide', tooltip: helpers.t('content_files.edit.fields.hide.tooltip_html')),
          TableHeader.new(label: 'Action')
        ]
      end
    end
  end
end
