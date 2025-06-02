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
      staging_filepath = staging_filepath_for(content_file)
      create_directory(staging_filepath)
      FileUtils.cp filepath, staging_filepath
    end

    def staging_filepath_for(content_file)
      File.join(staging_content_path, content_file.filepath)
    end

    def staging_content_path
      @staging_content_path ||= begin
        druid_tree_folder = DruidTools::Druid.new(druid, Settings.staging_location).path
        File.join(druid_tree_folder, 'content')
      end
    end

    def create_directory(filepath)
      FileUtils.mkdir_p File.dirname(filepath)
    end
  end
end
