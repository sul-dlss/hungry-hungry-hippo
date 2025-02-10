# frozen_string_literal: true

# Support methods for roundtrip validation.
class RoundtripSupport
  def self.normalize_cocina_object(cocina_object:)
    # Remove created_at and updated_at from the original cocina object
    lock = cocina_object&.lock
    norm_cocina_object = Cocina::Models.without_metadata(cocina_object)
    norm_cocina_object = norm_cocina_object.new(cocinaVersion: Cocina::Models::VERSION)

    Cocina::Models.with_metadata(norm_cocina_object, lock)
  end

  # @param [Cocina::Models::DRO,Cocina::Models::Collection] cocina_object
  # @return [Boolean] true if the provided cocina object is the same as a cocina object retrieved from SDR.
  def self.changed?(cocina_object:)
    original_cocina_object = Sdr::Repository.find(druid: cocina_object.externalIdentifier)
    cocina_object != normalize_cocina_object(cocina_object: original_cocina_object)
  end
end
