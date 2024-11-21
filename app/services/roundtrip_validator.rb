# frozen_string_literal: true

# Validates that a cocina object can be converted to an object form and then back without loss.
class RoundtripValidator
  def self.roundtrippable?(...)
    new(...).call
  end

  # @param [WorkForm, CollectionForm] form: a work_form or a collection_form
  # @param [Cocina::Models::DRO, Cocina::Models::Collection] cocina_object: a DRO or a Collection object
  # @param [ToWorkForm::Mapper, ToCocina::CollectionMapper] mapper: a mapper for the form
  def initialize(form:, cocina_object:, mapper:)
    @form = form
    @original_cocina_object = cocina_object
    @mapper = mapper
  end

  # @return [Boolean] true if the collection form can be converted to a cocina object and back without loss
  def call
    if roundtripped_cocina_object == normalized_original_cocina_object
      true
    else
      pretty_original = CocinaSupport.pretty(cocina_object: normalized_original_cocina_object)
      pretty_roundtripped = CocinaSupport.pretty(cocina_object: roundtripped_cocina_object)
      Honeybadger.notify('Roundtrip failed',
                         context: { original: pretty_original, roundtripped: pretty_roundtripped })
      Rails.logger.info("Roundtrip failed. Original: #{pretty_original}")
      Rails.logger.info("Roundtripped: #{pretty_roundtripped}")
      false
    end
  end

  private

  attr_reader :form, :content

  def roundtripped_cocina_object
    @mapper.call(form:,
                 source_id: normalized_original_cocina_object.identification&.sourceId)
  end

  def normalized_original_cocina_object
    @normalized_original_cocina_object ||= begin
      # Remove created_at and updated_at from the original cocina object
      lock = @original_cocina_object&.lock
      original_cocina_object_without_metadata = Cocina::Models.without_metadata(@original_cocina_object)
      Cocina::Models.with_metadata(original_cocina_object_without_metadata, lock)
    end
  end
end
