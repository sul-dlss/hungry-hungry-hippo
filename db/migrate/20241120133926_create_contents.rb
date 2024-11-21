class CreateContents < ActiveRecord::Migration[8.0]
  def change
    create_table :contents do |t|
      t.belongs_to :user, foreign_key: true

      t.timestamps
    end
  end
end
