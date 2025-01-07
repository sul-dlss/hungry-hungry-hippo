class RestoreNotNullToUsersName < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :name, false
  end
end
