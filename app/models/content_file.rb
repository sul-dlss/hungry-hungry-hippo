# frozen_string_literal: true

# Model for a content file
class ContentFile < ApplicationRecord
  before_save :set_filepath_parts
  belongs_to :content
  has_one_attached :file

  enum :file_type, attached: 'attached', deposited: 'deposited', globus: 'globus'

  scope :path_order, -> { order(path_parts: :asc).order('basename COLLATE "numeric"').order(extname: :asc) }
  scope :shown, -> { where(hide: false) }

  delegate :work, to: :content

  def hidden?
    hide
  end

  def set_filepath_parts
    self.path_parts = FilenameSupport.path_parts(filepath:)
    self.basename = FilenameSupport.basename(filepath:)
    self.extname = FilenameSupport.extname(filepath:)
  end

  # the path on the local staging filesystem
  # note: depending on status of the object (ie draft vs deposited), there is no guarantee the file will still be there
  def staging_filepath
    StagingSupport.staging_filepath(druid: content.work.druid, filepath:)
  end

  def filename
    FilenameSupport.filename(filepath:)
  end

  def path
    path_parts.join('/')
  end

  def pdf?
    mime_type == 'application/pdf'
  end

  def hierarchy?
    path_parts.present?
  end

  def filepath_on_disk
    if attached?
      ActiveStorageSupport.filepath_for_blob(file.blob)
    elsif globus?
      File.join(GlobusSupport.local_work_path(work:), filepath)
    end
  end
end
