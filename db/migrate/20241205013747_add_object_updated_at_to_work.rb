class AddObjectUpdatedAtToWork < ActiveRecord::Migration[8.0]
  def change
    add_column :works, :object_updated_at, :datetime
    add_index :works, :object_updated_at

    Work.all.find_each {|work| work.update!(object_updated_at: work.updated_at) }
  end
end
