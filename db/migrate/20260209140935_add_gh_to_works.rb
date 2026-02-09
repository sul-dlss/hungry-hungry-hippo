# frozen_string_literal: true

class AddGhToWorks < ActiveRecord::Migration[8.0]
  def change
    add_column :works, :github_repository_id, :bigint
    add_column :works, :github_repository_name, :string
    add_column :works, :github_deposit_enabled, :boolean, null: false, default: false

    add_index :works, :type
    add_index :works, :github_deposit_enabled
  end
end
