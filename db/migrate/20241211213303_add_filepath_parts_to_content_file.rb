class AddFilepathPartsToContentFile < ActiveRecord::Migration[8.0]
  def change
    add_column :content_files, :path_parts, :string, array: true
    add_column :content_files, :basename, :string
    add_column :content_files, :extname, :string
    rename_column :content_files, :filename, :filepath
  end
end
