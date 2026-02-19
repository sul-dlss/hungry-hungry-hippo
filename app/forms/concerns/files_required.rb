# frozen_string_literal: true

# Concern for requiring minimum and maximum file counts.
module FilesRequired
  extend ActiveSupport::Concern

  included do
    validate :min_content_file_count, on: :deposit
    validate :max_content_file_count
  end

  def min_content_file_count
    return if content_id.nil? # This makes test configuration easier.

    file_count = Content.find(content_id).content_files.count
    errors.add(:content, 'must have at least one file') if file_count.zero?
  end

  def max_content_file_count
    return if content_id.nil? # This makes test configuration easier.

    file_count = Content.find(content_id).content_files.count
    return unless file_count > Settings.file_upload.max_files

    errors.add(:content,
               "too many files (maximum is #{Settings.file_upload.max_files})")
  end
end
