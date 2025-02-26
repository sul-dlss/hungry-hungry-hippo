# frozen_string_literal: true

# Service for determining if a file provided by a user should be ignored.
class IgnoreFileService
  def self.call(...)
    new(...).call
  end

  def initialize(filepath:)
    @filepath = filepath
  end

  START_WITH_PATTERNS = ['__MACOSX', '._', '~$'].freeze
  END_WITH_PATTERNS = ['.DS_Store', "Icon\r"].freeze

  # @return [Boolean] true if the file should be ignored, false otherwise
  def call
    filepath.start_with?(*START_WITH_PATTERNS) \
    || File.basename(filepath).start_with?(*START_WITH_PATTERNS) \
    || filepath.end_with?(*END_WITH_PATTERNS)
  end

  private

  attr_reader :filepath
end
