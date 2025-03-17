# frozen_string_literal: true

class CreateContributor < ActiveRecord::Migration[8.0]
  def change
    create_table :contributors do |t|
      t.belongs_to :collection, foreign_key: true

      t.string :first_name
      t.string :last_name
      t.string :organization_name
      t.string :role
      t.string :role_type
      t.string :suborganization_name
      t.string :orcid
      t.boolean :cited, null: false, default: true

      t.timestamps
    end
  end
end
