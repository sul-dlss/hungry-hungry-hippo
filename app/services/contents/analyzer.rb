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

    attr_reader :content, :zip_file

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

      updates, buffer = process_stream(stream)
      updates[:mime_type] = mime_type_for(content_file:, buffer:)
      updates
    end

    def mime_type_for(content_file:, buffer:)
      if content_file.attached?
        content_file.file.blob.content_type
      else
        Marcel::MimeType.for(buffer,
                             name: content_file.filename)
      end
    end

    def process_stream(stream)
      md5 = Digest::MD5.new
      sha1 = Digest::SHA1.new
      first_buffer = nil
      while (buffer = stream.read(4096))
        first_buffer ||= buffer
        md5.update(buffer)
        sha1.update(buffer)
      end
      [{ md5_digest: md5.hexdigest, sha1_digest: sha1.hexdigest }, first_buffer]
    end

    def base64_to_hex(base64_string)
      binary_data = Base64.decode64(base64_string)
      binary_data.unpack1('H*')
    end

    def zip_filepath
      ActiveStorageSupport.filepath_for_blob(content.zip_file.blob)
    end
  end
end
