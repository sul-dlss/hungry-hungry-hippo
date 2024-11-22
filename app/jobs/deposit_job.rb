# frozen_string_literal: true

# Performs a deposit (without SDR API).
class DepositJob < ApplicationJob
  # @param [WorkForm, CollectionForm] form
  # @param [Work, Collection] object: the work or collection
  # @param [Boolean] deposit if true, deposit the work; otherwise, leave as draft
  def perform(form:, object:, deposit:)
    @form = form
    @object = object

    # cocina_object = ToCocina::Mapper.call(form:, content:, source_id:)
    new_cocina_object = perform_persist(update: @form.persisted?)
    druid = new_cocina_object.externalIdentifier
    Sdr::Repository.accession(druid:) if deposit

    # Refresh the wait page. Since the deposit job is finished, this will redirect to the show page.
    object.update!(deposit_job_started_at: nil, druid:)
    # Just to be aware for future troubleshooting: There is a possible race condition between the websocket
    # connecting and the following broadcast being sent.
    sleep 0.5 if Rails.env.test? # Avoids race condition in tests
    Turbo::StreamsChannel.broadcast_refresh_to 'wait', @object.id

    # If depositing a work, the content isn't needed anymore
    content.destroy! unless a_collection?
  end

  def perform_persist(update:)
    if update
      Sdr::Repository.open_if_needed(cocina_object:)
                     .then { |cocina_object| Sdr::Repository.update(cocina_object:) }
    else
      Sdr::Repository.register(cocina_object:)
    end
  end

  attr_reader :content, :form, :object

  private

  def a_collection?
    form.is_a?(CollectionForm)
  end

  def source_id
    return "h3:collection-#{object.id}" if a_collection?

    "h3:object-#{object.id}"
  end

  def cocina_object
    @cocina_object ||= if a_collection?
                         ToCocina::CollectionMapper.call(collection_form: form, source_id:)
                       else
                         @content = Content.find(@form.content_id)
                         ToCocina::WorkMapper.call(work_form: form, content:, source_id:)
                       end
  end
end
