# frozen_string_literal: true

# Verifies that a cocina object can be converted to a work form and then back without loss.
class WorkRoundtripper
  def self.call(...)
    new(...).call
  end

  # Perform a test setup of a WorkRoundtripper for troubleshooting purposes only.
  # @return [WorkRoundtripper] a new instance of WorkRoundtripper
  def self.troubleshooting_factory(druid:, notify: false)
    cocina_object = Sdr::Repository.find(druid:)
    work = Work.find_by(druid:)
    content = Contents::Builder.call(cocina_object:, user: work.user, work:)
    doi_assigned = DoiAssignedService.call(cocina_object:, work:)
    work_form = Form::WorkMapper.call(cocina_object:, doi_assigned:, agree_to_terms: true,
                                      version_description: 'test', collection: work.collection)
    new(work_form:, content:, cocina_object:, notify:)
  end

  # @param [WorkForm] work_form
  # @param [Content] content
  # @param [Cocina::Models::DRO] cocina_object
  # @param [boolean] notify if the validation fails
  def initialize(work_form:, content:, cocina_object:, notify: true)
    @work_form = work_form
    @content = content
    @original_cocina_object = cocina_object
    @notify = notify
  end

  # @return [Boolean] true if the work form can be converted to a cocina object and back without loss
  def call
    if roundtripped_cocina_object == normalized_original_cocina_object
      true
    else
      if notify
        RoundtripSupport.notify_error(original_cocina_object: normalized_original_cocina_object,
                                      roundtripped_cocina_object:)
      end
      false
    end
  rescue Cocina::Models::ValidationError => e
    # Generating the roundtripped cocina object may create an invalid object
    RoundtripSupport.notify_validation_error(error: e) if notify
    false
  end

  def roundtripped_cocina_object
    Cocina::WorkMapper.call(work_form:,
                            content:,
                            source_id: normalized_original_cocina_object.identification&.sourceId)
  end

  def normalized_original_cocina_object
    @normalized_original_cocina_object ||=
      RoundtripSupport.normalize_cocina_object(cocina_object: original_cocina_object)
  end

  attr_reader :original_cocina_object

  private

  attr_reader :work_form, :content, :notify
end
