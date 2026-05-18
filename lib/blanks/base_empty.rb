# frozen_string_literal: true

module Blanks
  # Provides default emptiness semantics for form objects.
  module BaseEmpty
    # Override in subclasses when emptiness depends on custom semantics.
    def empty?
      attributes.all? { |_name, value| value.blank? }
    end
  end
end
