# frozen_string_literal: true

class AddTypeToWork < ActiveRecord::Migration[8.0]
  def change
    add_column :works, :type, :string, null: false, default: 'Work'
  end
end
