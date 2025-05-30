# frozen_string_literal: true

module Works
  module Edit
    # Component for listing Globus links.
    class GlobusComponent < ApplicationComponent
      def initialize(globus_destination_path:, content_obj:)
        @destination_path = globus_destination_path
        @content_obj = content_obj
        super()
      end

      attr_reader :destination_path, :content_obj

      def sherlock_url
        GlobusSupport.endpoint_url(destination_path:, origin: 'sherlock')
      end

      def oak_url
        GlobusSupport.endpoint_url(destination_path:, origin: 'oak')
      end

      def stanford_gdrive_url
        GlobusSupport.endpoint_url(destination_path:, origin: 'stanford_gdrive')
      end

      def local_url
        GlobusSupport.endpoint_url(destination_path:)
      end
    end
  end
end
