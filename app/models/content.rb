# frozen_string_literal: true

# Model for a Work's content (files)
class Content < ApplicationRecord
  belongs_to :user
  has_many :content_files, dependent: :destroy

  def shown_files
    @shown_files ||= content_files.shown
  end

  # @return [Boolean] true if the content is consistent with a document object type
  def document?
    # All shown (not hidden) files must be PDFs and not be in a hierarchy
    # in order to be considered a document type
    shown_files.any? && shown_files.all?(&:pdf?) && shown_files.none?(&:hierarchy?)
  end
end
