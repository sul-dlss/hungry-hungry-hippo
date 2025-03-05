# frozen_string_literal: true

module Elements
  module Tables
    # Component for rendering a table header section.
    class HeaderComponent < ApplicationComponent
      def initialize(headers:, classes: [])
        @classes = classes
        @headers = objectify_headers(headers)
        super()
      end

      attr_reader :headers

      def render?
        headers.present?
      end

      def classes
        merge_classes(@classes)
      end

      def objectify_headers(headers)
        headers.map { |header| header.is_a?(TableHeader) ? header : TableHeader.new(label: header) }
      end
    end
  end
end
