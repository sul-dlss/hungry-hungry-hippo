# frozen_string_literal: true

# Model for a Work's content (files)
class Content < ApplicationRecord
  belongs_to :user
  belongs_to :work, optional: true
  has_many :content_files, dependent: :destroy

  state_machine :globus_state, initial: :globus_not_in_progress do
    event :globus_list do
      transition globus_not_in_progress: :globus_listing
    end

    event :globus_list_complete do
      transition globus_listing: :globus_not_in_progress
    end

    event :globus_list_cancel do
      transition globus_listing: :globus_not_in_progress
    end
  end

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
