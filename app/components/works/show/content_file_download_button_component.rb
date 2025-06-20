# frozen_string_literal: true

module Works
  module Show
    # Component for rendering a download button for a ContentFile.
    class ContentFileDownloadButtonComponent < ApplicationComponent
      def initialize(content_file:, data: {}, **opts)
        @content_file = content_file
        @data = data
        data[:turbo] = false
        @opts = opts
        super()
      end

      attr_reader :content_file, :data, :opts

      def call
        render Elements::IconButtonLinkComponent.new(icon: :download, label: 'Download file',
                                                     link: download_content_file_path(content_file),
                                                     data:, **opts)
      end
    end
  end
end
