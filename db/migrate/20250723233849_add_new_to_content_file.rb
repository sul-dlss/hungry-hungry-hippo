# frozen_string_literal: true

class AddNewToContentFile < ActiveRecord::Migration[8.0]
  def change
    add_column :content_files, :new, :boolean, default: false
  end
end
