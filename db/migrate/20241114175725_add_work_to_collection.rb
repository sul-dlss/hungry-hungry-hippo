class AddWorkToCollection < ActiveRecord::Migration[8.0]
  def change
    add_reference :collections, :work, null: false, foreign_key: true
  end
end
