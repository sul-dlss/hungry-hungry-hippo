# frozen_string_literal: true

# Model for a Work's content (files)
class Content < ApplicationRecord
  belongs_to :user
  has_many :content_files, dependent: :destroy
end
