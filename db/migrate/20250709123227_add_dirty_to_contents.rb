# frozen_string_literal: true

class AddDirtyToContents < ActiveRecord::Migration[8.0]
  def change
    add_column :contents, :dirty, :boolean, default: false, null: false
  end
end
