# frozen_string_literal: true

module Contents
  # Creates a Content from a Cocina object
  class Builder
    def self.call(...)
      new(...).call
    end

    def initialize(cocina_object:, user:, work: nil)
      @cocina_object = cocina_object
      @user = user
      @work = work
    end

    # @return [Content] the created content
    def call
      content = Content.create!(user:, work:)
      content_file_params = content_file_params_for(content:)
      # Adding in groups with insert_all is much faster than individual creates
      content_file_params.in_groups_of(1000, false) do |content_file_params_group|
        ContentFile.insert_all!(content_file_params_group) # rubocop:disable Rails/SkipsModelValidations
      end
      content
    end

    private

    attr_reader :cocina_object, :user, :work

    def content_file_params_for(content:) # rubocop:disable Metrics/AbcSize
      cocina_object.structural.contains.flat_map do |file_set|
        file_set.structural.contains.map do |file|
          filepath = file.filename
          {
            file_type: :deposited,
            filepath:,
            path_parts: FilenameSupport.path_parts(filepath:),
            basename: FilenameSupport.basename(filepath:),
            extname: FilenameSupport.extname(filepath:),
            label: file_set.label,
            external_identifier: file.externalIdentifier,
            fileset_external_identifier: file_set.externalIdentifier,
            size: file.size,
            mime_type: file.hasMimeType,
            md5_digest: digest_for(type: 'md5', file:),
            sha1_digest: digest_for(type: 'sha1', file:),
            content_id: content.id,
            hide: !file.administrative.shelve
          }
        end
      end
    end

    def digest_for(type:, file:)
      file.hasMessageDigests.find { |digest| digest.type == type }&.digest
    end
  end
end
