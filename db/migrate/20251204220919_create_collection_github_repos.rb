# frozen_string_literal: true

class CreateCollectionGithubRepos < ActiveRecord::Migration[8.0]
  def change
    create_table :collection_github_repos do |t|
      t.references :collection, null: false, foreign_key: true
      t.string :github_repo_id
      t.string :github_repo_name

      t.timestamps
    end
  end
end
