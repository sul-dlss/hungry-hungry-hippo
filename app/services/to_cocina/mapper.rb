# frozen_string_literal: true

module ToCocina
  # Maps WorkForm to Cocina DRO
  class Mapper
    def self.call(...)
      new(...).call
    end

    # @param [WorkForm] work_form
    # @param [source_id] source_id
    def initialize(work_form:, source_id:)
      @work_form = work_form
      @content = content
      @source_id = source_id
    end

    # @return [Cocina::Models::DROWithMetadata, Cocina::Models::RequestDRO]
    def call
      if work_form.persisted?
        Cocina::Models.with_metadata(Cocina::Models.build(params), work_form.lock)
      else
        Cocina::Models.build_request(params)
      end
    end

    private

    attr_reader :work_form, :source_id, :content

    def params
      {
        externalIdentifier: work_form.druid,
        type: Cocina::Models::ObjectType.object,
        label: work_form.title,
        description: ToCocina::DescriptionMapper.call(form: work_form),
        version: work_form.version,
        access: { view: 'world', download: 'world' },
        identification: { sourceId: source_id },
        administrative: { hasAdminPolicy: Settings.apo },
        structural: {}
      }.compact
    end
  end
end
