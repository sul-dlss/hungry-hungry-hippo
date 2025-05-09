# frozen_string_literal: true

# Model for a Work's content (files)
class Content < ApplicationRecord
  belongs_to :user
  belongs_to :work, optional: true
  has_many :content_files, dependent: :destroy

  def shown_files
    content_files.shown
  end
end
