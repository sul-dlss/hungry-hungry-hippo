# frozen_string_literal: true

class AddMessageToGithubReleases < ActiveRecord::Migration[8.0]
  def change
    add_column :github_releases, :message, :jsonb, null: false, default: {}
    remove_column :github_releases, :zip_url, :string
  end
end
