# frozen_string_literal: true

# Verifies that a cocina object can be converted to a work form and then back without loss.
class WorkRoundtripper
  def self.call(...)
    new(...).call
  end

  # @param [WorkForm] work_form
  # @param [Content] content
  # @param [Cocina::Models::DRO] cocina_object
  def initialize(work_form:, content:, cocina_object:)
    @work_form = work_form
    @content = content
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
  rescue Cocina::Models::ValidationError
    # Generating the roundtripped cocina object may create an invalid object
    false
  end

  private

  attr_reader :work_form, :content

  def roundtripped_cocina_object
    Cocina::WorkMapper.call(work_form:,
                            content:,
                            source_id: normalized_original_cocina_object.identification&.sourceId)
  end

  def normalized_original_cocina_object
    @normalized_original_cocina_object ||= RoundtripSupport.normalize_cocina_object(
      cocina_object: @original_cocina_object
    )
  end
end
