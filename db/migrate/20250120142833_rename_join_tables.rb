class RenameJoinTables < ActiveRecord::Migration[8.0]
  def change
    rename_table :depositors, :collection_depositors
    rename_table :managers, :collection_managers
    rename_table :reviewers, :collection_reviewers
  end
end
