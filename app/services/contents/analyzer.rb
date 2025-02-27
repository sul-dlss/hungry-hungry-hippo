# frozen_string_literal: true

module Contents
  # Adds MD5, SHA1 and mime type to Content Files since needed for deposit.
  class Analyzer
    def self.call(...)
      new(...).call
    end

    # @param [Content] content
    def initialize(content:)
      @content = content
    end

    def call
      content.content_files.each do |content_file|
        next unless content_file.attached?

        content_file.update!(updates_for(content_file))
      end
    end

    private

    attr_reader :content

    def updates_for(content_file)
      updates = if content_file.md5_digest.present? && content_file.sha1_digest.present?
                  {}
                else
                  digest_updates_for(content_file)
                end
      updates[:mime_type] = content_file.file.blob.content_type if content_file.mime_type.blank?
      updates
    end

    def digest_updates_for(content_file)
      stream = File.open(ActiveStorageSupport.filepath_for_blob(content_file.file.blob))

      md5 = Digest::MD5.new
      sha1 = Digest::SHA1.new
      while (buffer = stream.read(4096))
        md5.update(buffer)
        sha1.update(buffer)
      end

      { md5_digest: md5.hexdigest, sha1_digest: sha1.hexdigest }
    end
  end
end
