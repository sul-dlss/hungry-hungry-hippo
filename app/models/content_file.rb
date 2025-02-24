# frozen_string_literal: true

# Model for a content file
class ContentFile < ApplicationRecord
  before_save :set_filepath_parts
  belongs_to :content
  has_one_attached :file

  enum :file_type, attached: 'attached', deposited: 'deposited'

  scope :path_order, -> { order(path_parts: :asc).order('basename COLLATE "numeric"').order(extname: :asc) }
  scope :shown, -> { where(hide: false) }

  def hidden?
    hide
  end

  def set_filepath_parts
    self.path_parts = FilenameSupport.path_parts(filepath:)
    self.basename = FilenameSupport.basename(filepath:)
    self.extname = FilenameSupport.extname(filepath:)
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
end
