class AddDepositorsAndManagersJoinTables < ActiveRecord::Migration[8.0]
  def change
    create_join_table :collections, :users, table_name: :depositors do |t|
      t.index [:collection_id, :user_id], unique: true
    end

    create_join_table :collections, :users, table_name: :managers do |t|
      t.index [:collection_id, :user_id], unique: true
    end
  end
end
