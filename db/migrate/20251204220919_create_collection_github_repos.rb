# frozen_string_literal: true

class CreateCollectionGithubRepos < ActiveRecord::Migration[8.0]
  def change
    create_table :github_repos do |t|
      t.references :collection, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :work, null: false, foreign_key: true
      t.string :repo_id
      t.string :repo_name
      t.integer :webhook_id

      t.timestamps
    end
  end
end
