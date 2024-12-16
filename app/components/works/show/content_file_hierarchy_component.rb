# frozen_string_literal: true

module Works
  module Show
    # Component for rendering a file hierarchy table for a Content.
    class ContentFileHierarchyComponent < ApplicationComponent
      def initialize(content_file:, last_path_parts:, component:)
        @content_file = content_file
        @last_path_parts = last_path_parts
        @component = component
        super()
      end

      attr_reader :content_file, :component

      delegate :path_parts, :filename, to: :content_file

      def style_for(level)
        "padding-left: #{level * 25}px"
      end

      # Determine the difference between the last filepath parts and the current filepath parts.
      def new_path_parts
        ComponentSupport::FileHierarchy.path_parts_diff(last_path_parts: @last_path_parts,
                                                        path_parts:)
      end
    end
  end
end
