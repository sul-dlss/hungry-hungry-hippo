# frozen_string_literal: true

module ComponentSupport
  # Helper methods for CSS classes.
  class CssClasses
    # Merge classes together.
    #
    # @param args [Array<String>, String] The classes to merge (array, classes, space separated classes).
    # @return [String] The merged classes.
    def self.merge(*args)
      args.map do |arg|
        Array(arg&.split)
      end.flatten.compact.uniq.join(' ').presence
    end
  end
end
