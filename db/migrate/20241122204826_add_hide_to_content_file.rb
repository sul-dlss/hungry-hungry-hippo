class AddHideToContentFile < ActiveRecord::Migration[8.0]
  def change
    add_column :content_files, :hide, :boolean, default: false, null: false
  end
end
