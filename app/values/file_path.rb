# frozen_string_literal: true

# Value object for filepaths
class FilePath
  def self.basename(...)
    new(...).basename
  end

  def self.extname(...)
    new(...).extname
  end

  def self.filename(...)
    new(...).filename
  end

  def self.parts(...)
    new(...).parts
  end

  # @param [<String>] path a file path in string form
  def initialize(path)
    @path = path
  end

  # @return [Array<String>] the parts of the path or an empty array if no path
  def parts
    return [] if dirname == '.'

    dirname.split('/')
  end

  # @return [String,nil] the basename of the file (e.g., "file" for "file.txt") or nil if no file
  def basename
    return if path.nil?

    File.basename(path, '.*')
  end

  # @return [String,nil] the extension of the file (e.g., "txt" for "file.txt") or nil if no file
  def extname
    return if path.nil?

    File.extname(path).delete_prefix('.')
  end

  # @return [String,nil] the filename of the file (e.g., "file.txt" for "dir/file.txt") or nil if no file
  def filename
    return if path.nil?

    File.basename(path)
  end

  def to_s
    path
  end

  private

  attr_reader :path

  def dirname
    File.dirname(path.to_s)
  end
end
