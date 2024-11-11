# frozen_string_literal: true

# Performs a deposit (without SDR API).
class DepositJob < ApplicationJob
  # @param [WorkForm] work_form
  # @param [Boolean] deposit if true, deposit the work; otherwise, leave as draft
  def perform(work_form:, deposit:)
    cocina_object = ToCocina::Mapper.call(work_form:, source_id: source_id)
    # Until we're also doing updates:
    new_cocina_object = Sdr::Repository.register(cocina_object:)
    # new_cocina_object = if work_form.persisted?
    #                       Sdr::Repository.open_if_needed(cocina_object:)
    #                                      .then { |cocina_object| Sdr::Repository.update(cocina_object:) }
    #                     else
    #                       Sdr::Repository.register(cocina_object:)
    #                     end
    druid = new_cocina_object.externalIdentifier
    Sdr::Repository.accession(druid:) if deposit
  end

  def source_id
    "h3:object-#{Time.zone.now.iso8601}"
    # This is temporary until we have a work object and can do "h3:object-#{work.id}"
  end
end
