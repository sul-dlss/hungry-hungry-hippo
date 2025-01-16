# frozen_string_literal: true

# Support methods for roundtrip validation.
class RoundtripValidatorSupport
  def self.normalize_cocina_object(cocina_object:)
    # Remove created_at and updated_at from the original cocina object
    lock = cocina_object&.lock
    norm_cocina_object = Cocina::Models.without_metadata(cocina_object)
    norm_cocina_object = norm_cocina_object.new(cocinaVersion: Cocina::Models::VERSION)

    Cocina::Models.with_metadata(norm_cocina_object, lock)
  end
end
