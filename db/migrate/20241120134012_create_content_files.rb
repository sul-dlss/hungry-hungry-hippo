class CreateContentFiles < ActiveRecord::Migration[8.0]
  def change
    create_table :content_files do |t|
      t.string :file_type, null: false
      t.string :filename, null: false
      t.string :label, null: false
      t.string :external_identifier
      t.string :fileset_external_identifier
      t.integer :size
      t.string :mime_type
      t.string :md5_digest
      t.string :sha1_digest
      t.references :content, null: false, foreign_key: true
      t.timestamps
      t.index [:content_id, :filename], unique: true
    end
  end
end
