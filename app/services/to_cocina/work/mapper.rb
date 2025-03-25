# frozen_string_literal: true

module ToCocina
  module Work
    # Maps WorkForm to Cocina DRO
    class Mapper
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
          description: DescriptionMapper.call(work_form:),
          version: work_form.version,
          access: AccessMapper.call(work_form:),
          identification: IdentificationMapper.call(work_form:, source_id:),
          administrative: { hasAdminPolicy: Settings.apo },
          structural: StructuralMapper.call(work_form:, content:, document: document?)
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
        # All shown (not hidden) files must be PDFs and not be in a hierarchy
        # in order to be considered a document type
        shown_files.any? && shown_files.all?(&:pdf?) && shown_files.none?(&:hierarchy?)
      end

      def shown_files
        @shown_files ||= content.shown_files
      end
    end
  end
end
