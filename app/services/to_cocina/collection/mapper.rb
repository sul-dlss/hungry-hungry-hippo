# frozen_string_literal: true

module ToCocina
  module Collection
    # Maps CollectionForm to Cocina Collection
    class Mapper
      def self.call(...)
        new(...).call
      end

      # @param [CollectionForm] collection_form
      # @param [source_id] source_id
      def initialize(collection_form:, source_id:)
        @collection_form = collection_form
        @source_id = source_id
      end

      # @return [Cocina::Models::CollectionWithMetadata, Cocina::Models::RequestCollection]
      def call
        if collection_form.persisted?
          Cocina::Models.with_metadata(Cocina::Models.build(params), collection_form.lock)
        else
          Cocina::Models.build_request(request_params)
        end
      end

      private

      attr_reader :collection_form, :source_id

      def params
        {
          externalIdentifier: collection_form.druid,
          type: Cocina::Models::ObjectType.collection,
          label: collection_form.title,
          description: ToCocina::Collection::DescriptionMapper.call(collection_form:),
          version: collection_form.version,
          access:,
          identification: { sourceId: source_id },
          administrative: { hasAdminPolicy: Settings.apo }
        }.compact
      end

      def request_params
        params.tap do |params_hash|
          params_hash[:administrative][:partOfProject] = Settings.project_tag
        end
      end

      def access
        return { view: 'world' } unless collection_form.license.present?

        { view: 'world', license: collection_form.license }
      end
    end
  end
end
