# frozen_string_literal: true

# Model for a content file
class ContentFile < ApplicationRecord
  before_save :set_file_path_parts
  belongs_to :content
  has_one_attached :file

  enum :file_type, attached: 'attached', deposited: 'deposited'

  scope :path_order, -> { order(path_parts: :asc).order('basename COLLATE "numeric"').order(extname: :asc) }
  scope :shown, -> { where(hide: false) }

  delegate :filename, :parts, :basename, :extname, to: :file_path

  def hidden?
    hide
  end

  def set_file_path_parts
    self.path_parts = parts
    self.basename = basename
    self.extname = extname
  end

  def path
    parts.join('/')
  end

  def pdf?
    mime_type == 'application/pdf'
  end

  private

  def file_path
    FilePath.new(filepath)
  end
end
