# frozen_string_literal: true

class WorkMapper
  # Maps Content to a Cocina structural
  class StructuralMapper
    ID_NAMESPACE = 'https://cocina.sul.stanford.edu'

    def self.call(...)
      new(...).call
    end

    # @param [WorkForm] work_form
    # @param [Content] content
    # @param [boolean] whether the object type is document
    def initialize(work_form:, content:, document:)
      @work_form = work_form
      @content = content
      @document = document
    end

    def call
      if work_form.persisted?
        Cocina::Models::DROStructural.new(params)
      else
        Cocina::Models::RequestDROStructural.new(params)
      end
    end

    private

    attr_reader :work_form, :content

    delegate :access, to: :work_form

    def params
      {
        contains: content.content_files.map { |content_file| fileset_params_for(content_file) },
        isMemberOf: [work_form.collection_druid]
      }
    end

    def fileset_params_for(content_file)
      # one file per fileset
      {
        type: fileset_type_for(content_file),
        version: work_form.version,
        label: content_file.label,
        externalIdentifier: fileset_external_identifier_for(content_file),
        structural: {
          contains: [file_params_for(content_file)]
        }
      }.compact
    end

    def file_params_for(content_file)
      {
        type: Cocina::Models::ObjectType.file,
        version: work_form.version,
        label: content_file.label,
        filename: content_file.filepath,
        access: { view: access, download: access },
        administrative: { publish: !content_file.hidden?, sdrPreserve: true, shelve: !content_file.hidden? },
        hasMimeType: content_file.mime_type,
        hasMessageDigests: message_digests_for(content_file),
        size: content_file.size,
        externalIdentifier: file_external_identifier_for(content_file)
      }.compact
    end

    def fileset_external_identifier_for(content_file)
      if !work_form.persisted?
        nil
      elsif content_file.fileset_external_identifier.present?
        content_file.fileset_external_identifier
      else
        # see https://github.com/sul-dlss/dor-services-app/blob/main/app/services/cocina/id_generator.rb
        "#{ID_NAMESPACE}/fileSet/#{bare_druid}-#{SecureRandom.uuid}"
      end
    end

    def file_external_identifier_for(content_file)
      if !work_form.persisted?
        nil
      elsif content_file.fileset_external_identifier.present?
        content_file.external_identifier
      else
        # see https://github.com/sul-dlss/dor-services-app/blob/main/app/services/cocina/id_generator.rb
        "#{ID_NAMESPACE}/file/#{bare_druid}-#{SecureRandom.uuid}"
      end
    end

    def bare_druid
      work_form.druid.delete_prefix('druid:')
    end

    def message_digests_for(content_file)
      [].tap do |digests|
        digests << { type: 'md5', digest: content_file.md5_digest } if content_file.md5_digest.present?
        digests << { type: 'sha1', digest: content_file.sha1_digest } if content_file.sha1_digest.present?
      end
    end

    def document?
      @document
    end

    def fileset_type_for(content_file)
      return Cocina::Models::FileSetType.document if document? && content_file.pdf? && !content_file.hidden?

      Cocina::Models::FileSetType.file
    end
  end
end
