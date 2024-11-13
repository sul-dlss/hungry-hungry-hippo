# frozen_string_literal: true

# Helpers for working with Cocina objects
class CocinaSupport
  def self.title_for(cocina_object:)
    cocina_object.description.title.first.value
  end
end
