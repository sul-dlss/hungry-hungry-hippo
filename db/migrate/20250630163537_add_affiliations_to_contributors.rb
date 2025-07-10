# frozen_string_literal: true

class AddAffiliationsToContributors < ActiveRecord::Migration[8.0]
  def change
    create_table :affiliations do |t|
      t.belongs_to :contributor, foreign_key: true

      t.string :institution, null: false
      t.string :uri, null: false
      t.string :department

      t.timestamps
    end
  end
end
