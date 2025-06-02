# frozen_string_literal: true

module Contents
  # Service to copy content files to the workspace.
  class Stager
    def self.call(...)
      new(...).call
    end

    def initialize(content:, druid:)
      @content = content
      @druid = druid
    end

    def call
      content.content_files.each do |content_file|
        next unless content_file.attached? || content_file.globus?

        stage_content(content_file)
      end
    end

    private

    attr_reader :content, :druid, :zip_file

    def stage_content(content_file)
      filepath = content_file.filepath_on_disk
      staging_filepath = StagingSupport.staging_filepath(druid:, filepath: content_file.filepath)
      create_directory(staging_filepath)
      FileUtils.cp filepath, staging_filepath
    end

    def create_directory(filepath)
      FileUtils.mkdir_p File.dirname(filepath)
    end
  end
end
