# frozen_string_literal: true

# The containing namespace for mappers indicates what is being mapped *to*
module Cocina
  # Maps WorkForm to Cocina DRO (AKA "item" or "work")
  class WorkMapper
    def self.call(...)
      new(...).call
    end

    # @param [WorkForm] work_form
    # @param [Content] content
    # @param [source_id] source_id
    def initialize(work_form:, content:, source_id:)
      @work_form = work_form
      @content = content
      @source_id = source_id
    end

    # @return [Cocina::Models::DROWithMetadata, Cocina::Models::RequestDRO]
    def call
      if work_form.persisted?
        Cocina::Models.with_metadata(Cocina::Models.build(params), work_form.lock)
      else
        Cocina::Models.build_request(request_params)
      end
    end

    private

    attr_reader :work_form, :source_id, :content

    def params # rubocop:disable Metrics/AbcSize
      {
        externalIdentifier: work_form.druid,
        type: object_type,
        label: work_form.title,
        description: WorkDescriptionMapper.call(work_form:),
        version: work_form.version,
        access: WorkAccessMapper.call(work_form:),
        identification: WorkIdentificationMapper.call(work_form:, source_id:),
        administrative: { hasAdminPolicy: work_form.apo },
        structural: WorkStructuralMapper.call(work_form:, content:, document: document?)
      }.compact
    end

    def request_params
      params.tap do |params_hash|
        params_hash[:administrative][:partOfProject] = Settings.project_tag
      end
    end

    def object_type
      document? ? Cocina::Models::ObjectType.document : Cocina::Models::ObjectType.object
    end

    def document?
      @document ||= content.document?
    end
  end
end
