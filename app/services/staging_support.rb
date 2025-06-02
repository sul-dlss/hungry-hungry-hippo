# frozen_string_literal: true

# Methods for staging support, such as constructing file paths.
class StagingSupport
  def self.staging_filepath(druid:, filepath:)
    File.join(staging_content_path(druid:), filepath)
  end

  def self.staging_content_path(druid:)
    druid_tree_folder = DruidTools::Druid.new(druid, Settings.staging_location).path
    File.join(druid_tree_folder, 'content')
  end
end
