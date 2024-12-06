class DropNotNullFromUsers < ActiveRecord::Migration[8.0]
  def change
    change_column_null :users, :name, true
    change_column_null :users, :first_name, true
  end
end
