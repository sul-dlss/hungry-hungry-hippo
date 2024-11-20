# frozen_string_literal: true

# Model for a Work's content (files)
class Content < ApplicationRecord
  has_many :content_files, dependent: :destroy
end
