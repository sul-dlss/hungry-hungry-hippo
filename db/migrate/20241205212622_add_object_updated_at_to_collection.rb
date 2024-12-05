class AddObjectUpdatedAtToCollection < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :object_updated_at, :datetime
    add_index :collections, :object_updated_at

    Collection.all.find_each {|collection| collection.update!(object_updated_at: collection.updated_at) }
  end
end
