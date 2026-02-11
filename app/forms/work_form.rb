# frozen_string_literal: true

# Form for a Work
class WorkForm < BaseWorkForm
  # As new subclasses of BaseWorkForm are created, WorkForm specific validations and callbacks will be moved here.
  validate :min_content_file_count, on: :deposit
  validate :max_content_file_count

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

  def default_tab
    :files
  end

  def render_tabs
    %i[files title contributors abstract types doi access license dates related_content citation]
  end
end
