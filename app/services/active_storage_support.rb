# frozen_string_literal: true

# Helpers for working with ActiveStorage.
class ActiveStorageSupport
  def self.filepath_for_blob(blob)
    ActiveStorage::Blob.service.path_for(blob.key)
  end
end
