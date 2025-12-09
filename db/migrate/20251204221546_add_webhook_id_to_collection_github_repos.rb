# frozen_string_literal: true

class AddWebhookIdToCollectionGithubRepos < ActiveRecord::Migration[8.0]
  def change
    add_column :collection_github_repos, :webhook_id, :integer
  end
end
