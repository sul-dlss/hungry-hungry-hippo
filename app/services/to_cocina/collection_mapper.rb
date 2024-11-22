# frozen_string_literal: true

module ToCocina
  # Maps Collectioncollection_form to Cocina Collection
  class CollectionMapper
    def self.call(...)
      new(...).call
    end

    # @param [CollectionForm] collection_form
    # @param [source_id] source_id
    # param [content] content: For collections, this is always nil
    def initialize(collection_form:, source_id:)
      @collection_form = collection_form
      @source_id = source_id
    end

    # @return [Cocina::Models::Collection]
    def call
      if collection_form.persisted?
        Cocina::Models.with_metadata(Cocina::Models.build(params), collection_form.lock)
      else
        Cocina::Models.build_request(params)
      end
    end

    private

    attr_reader :collection_form, :source_id, :content

    def params
      {
        externalIdentifier: collection_form.druid,
        type: Cocina::Models::ObjectType.collection,
        label: collection_form.title,
        description: ToCocina::DescriptionMapper.call(form: collection_form),
        version: collection_form.version,
        access: { view: 'world' },
        identification: { sourceId: source_id },
        administrative: { hasAdminPolicy: Settings.apo }
      }.compact
    end
  end
end
