# frozen_string_literal: true

module ComponentSupport
  # Support methods for working with file hierarchies.
  class FileHierarchy
    # Determine the difference between the last path parts and the current path parts.
    # @param [Array<String>] last_path_parts the last path parts (e.g., ['dir1', 'dir2'])
    # @param [Array<String>] path_parts the current path parts
    # @return [Array<String>] path parts from the current path parts that differ
    def self.path_parts_diff(last_path_parts:, path_parts:)
      return [] if last_path_parts == path_parts

      matching_index = 0
      loop do
        break if path_parts[matching_index] != last_path_parts[matching_index]

        matching_index += 1
      end
      path_parts.slice(matching_index..)
    end
  end
end
