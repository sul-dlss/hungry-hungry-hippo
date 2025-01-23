class AddVersionToWorkAndCollection < ActiveRecord::Migration[8.0]
  def change
    add_column :works, :version, :integer, default: 1, null: false
    add_column :collections, :version, :integer, default: 1, null: false
  end
end
