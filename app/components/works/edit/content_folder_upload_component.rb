# frozen_string_literal: true

module Works
  module Edit
    # Component for uploading to a content folder
    class ContentFolderUploadComponent < ApplicationComponent
      def initialize(path:)
        @path = path
        super
      end

      attr_reader :path

      def data
        {
          controller: 'dropzone-folder',
          action: 'dropzone-folder#setBasePath',
          dropzone_folder_path_value: path,
          dropzone_folder_dropzone_outlet: '.dropzone'
        }
      end
    end
  end
end
