# frozen_string_literal: true

module ToCocina
  # Maps CollectionForm to Cocina Collection
  class CollectionMapper
    def self.call(...)
      new(...).call
    end

    # @param [CollectionForm] form
    # @param [source_id] source_id
    # param [content] content: For collections, this is always nil
    def initialize(form:, source_id:, content: nil)
      @form = form
      @content = content # Requred for interface compatibility with ToCocina::Mapper
      @source_id = source_id
    end

    # @return [Cocina::Models::Collection]
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
        type: Cocina::Models::ObjectType.collection,
        label: form.title,
        description: ToCocina::DescriptionMapper.call(form: form),
        version: form.version,
        access: { view: 'world' },
        identification: { sourceId: source_id },
        administrative: { hasAdminPolicy: Settings.apo }
      }.compact
    end
  end
end
