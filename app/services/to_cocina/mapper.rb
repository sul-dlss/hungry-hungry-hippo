# frozen_string_literal: true

module ToCocina
  # Maps WorkForm to Cocina DRO
  class Mapper
    def self.call(...)
      new(...).call
    end

    # @param [WorkForm] form
    # @param [source_id] source_id
    def initialize(form:, content:, source_id:)
      @form = form
      @content = content
      @source_id = source_id
    end

    # @return [Cocina::Models::DROWithMetadata, Cocina::Models::RequestDRO]
    def call
      if form.persisted?
        Cocina::Models.with_metadata(Cocina::Models.build(params), form.lock)
      else
        Cocina::Models.build_request(params)
      end
    end

    private

    attr_reader :form, :source_id, :content

    def params
      {
        externalIdentifier: form.druid,
        type: Cocina::Models::ObjectType.object,
        label: form.title,
        description: ToCocina::DescriptionMapper.call(form: form),
        version: form.version,
        access: { view: 'world', download: 'world' },
        identification: { sourceId: source_id },
        administrative: { hasAdminPolicy: Settings.apo },
        structural: ToCocina::StructuralMapper.call(work_form: form, content:)
      }.compact
    end
  end
end
