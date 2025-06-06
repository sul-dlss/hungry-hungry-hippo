# frozen_string_literal: true

# Verifies that a cocina object can be converted to a collection form and then back without loss.
class CollectionRoundtripper
  def self.call(...)
    new(...).call
  end

  # @param [CollectoinForm] collection_form
  # @param [Cocina::Models::Collection] cocina_object
  def initialize(collection_form:, cocina_object:)
    @collection_form = collection_form
    @original_cocina_object = cocina_object
  end

  # @return [Boolean] true if the work form can be converted to a cocina object and back without loss
  def call
    if roundtripped_cocina_object == normalized_original_cocina_object
      true
    else
      RoundtripSupport.notify_error(original_cocina_object: normalized_original_cocina_object,
                                    roundtripped_cocina_object:)
      false
    end
  rescue Cocina::Models::ValidationError => e
    # Generating the roundtripped cocina object may create an invalid object
    RoundtripSupport.notify_validation_error(error: e)
    false
  end

  private

  attr_reader :collection_form, :content

  def roundtripped_cocina_object
    Cocina::CollectionMapper.call(collection_form:,
                                  source_id: normalized_original_cocina_object.identification&.sourceId)
  end

  def normalized_original_cocina_object
    @normalized_original_cocina_object ||=
      RoundtripSupport.normalize_cocina_object(cocina_object: @original_cocina_object)
  end
end
