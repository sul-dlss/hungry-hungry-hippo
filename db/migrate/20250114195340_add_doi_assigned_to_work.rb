class AddDoiAssignedToWork < ActiveRecord::Migration[8.0]
  def change
    add_column :works, :doi_assigned, :boolean, default: false, null: false
  end
end
