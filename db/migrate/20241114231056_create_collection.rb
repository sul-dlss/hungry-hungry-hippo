class CreateCollection < ActiveRecord::Migration[8.0]
  def change
    create_table :collections do |t|
      t.string :druid, null: false
      t.string :title, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
