# frozen_string_literal: true

# Support for working with filenames
class FilenameSupport
  # @return [String,nil] the path of the file or nil if no path
  def self.path(filepath:)
    return if filepath.nil?

    if (path = File.dirname(filepath)) == '.'
      nil
    else
      path
    end
  end

  # @return [Array<String>] the parts of the path or an empty array if no path
  def self.path_parts(filepath:)
    path(filepath:)&.split('/') || []
  end

  # @return [String,nil] the basename of the file (e.g., "file" for "file.txt") or nil if no file
  def self.basename(filepath:)
    return if filepath.nil?

    File.basename(filepath, '.*')
  end

  # @return [String,nil] the extension of the file (e.g., "txt" for "file.txt") or nil if no file
  def self.extname(filepath:)
    return if filepath.nil?

    File.extname(filepath).delete_prefix('.')
  end

  # @return [String,nil] the filename of the file (e.g., "file.txt" for "dir/file.txt") or nil if no file
  def self.filename(filepath:)
    return if filepath.nil?

    File.basename(filepath)
  end
end
