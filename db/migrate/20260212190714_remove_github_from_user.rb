# frozen_string_literal: true

class RemoveGithubFromUser < ActiveRecord::Migration[8.0]
  def change
    remove_index :users, :github_uid

    remove_column :users, :github_updated_at, :datetime
    remove_column :users, :github_connected_at, :datetime
    remove_column :users, :github_nickname, :string
    remove_column :users, :github_uid, :string
    remove_column :users, :github_access_token, :string
  end
end
