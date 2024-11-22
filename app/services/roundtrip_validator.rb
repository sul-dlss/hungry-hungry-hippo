# frozen_string_literal: true

# Validates that a cocina object can be converted to a work form and then back without loss.
class RoundtripValidator
  def self.roundtrippable?(...)
    new(...).call
  end

  # @param [WorkForm, CollectionForm] form: a WorkForm or a CollectionForm
  # @param [Content] content
  # @param [Cocina::Models::DRO, Cocina::Models::Collection] cocina_object
  def initialize(form:, cocina_object:, content: nil)
    @form = form
    @content = content
    @original_cocina_object = cocina_object
  end

  # @return [Boolean] true if the work form can be converted to a cocina object and back without loss
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

  def a_collection?
    form.is_a?(CollectionForm)
  end

  def roundtripped_cocina_object
    if a_collection?
      ToCocina::CollectionMapper.call(collection_form: form,
                                      source_id: normalized_original_cocina_object.identification&.sourceId)
    else
      ToCocina::WorkMapper.call(work_form: form,
                                content:,
                                source_id: normalized_original_cocina_object.identification&.sourceId)
    end
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
