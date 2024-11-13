class CreateWork < ActiveRecord::Migration[8.0]
  def change
    create_table :works do |t|
      t.string :druid
      t.string :title, null: false
      t.belongs_to :user, foreign_key: true
      t.datetime :deposit_job_started_at

      t.timestamps
      t.index :druid, unique: true
    end
  end
end
