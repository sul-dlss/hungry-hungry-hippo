# frozen_string_literal: true

class ChangeContentFileSize < ActiveRecord::Migration[8.0]
  def change
    change_column :content_files, :size, :bigint
  end
end
