# frozen_string_literal: true

class AddGithubTokenToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :github_access_token, :string
    add_column :users, :github_uid, :string
    add_column :users, :github_nickname, :string
    add_column :users, :github_connected_date, :datetime

    add_index :users, :github_uid, unique: true
  end
end
