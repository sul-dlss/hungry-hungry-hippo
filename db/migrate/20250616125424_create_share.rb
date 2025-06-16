# frozen_string_literal: true

class CreateShare < ActiveRecord::Migration[8.0]
  def change
    create_table :shares do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :work, null: false, foreign_key: true
      t.string :permission, null: false, default: 'view'

      t.timestamps
    end
  end
end
