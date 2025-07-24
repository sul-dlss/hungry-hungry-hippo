# frozen_string_literal: true

module Works
  module Edit
    # Component for rendering an editable file hierarchy row for a ContentFile.
    class ContentFileHierarchyComponent < ApplicationComponent
      def initialize(content_file:, last_path_parts:, component:)
        @content_file = content_file
        @last_path_parts = last_path_parts
        @component = component
        super()
      end

      attr_reader :content_file, :component

      delegate :path_parts, :filename, :path, to: :content_file

      def style_for(level)
        "padding-left: #{level * 25}px"
      end

      # Determine the difference between the last filepath parts and the current filepath parts.
      def new_path_parts
        @new_path_parts ||= ComponentSupport::FileHierarchy.path_parts_diff(last_path_parts: @last_path_parts,
                                                                            path_parts:)
      end

      def upload_path_for(level)
        range_end = path_parts.length - new_path_parts.length + level
        path_parts.slice(0..range_end).join('/')
      end

      def badge_content
        'New' if content_file.new?
      end
    end
  end
end
