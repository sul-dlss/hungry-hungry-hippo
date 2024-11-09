class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      t.string :name, null: false
      t.string :first_name, null: false

      t.timestamps
    end
    add_index :users, :email_address, unique: true
  end
end
