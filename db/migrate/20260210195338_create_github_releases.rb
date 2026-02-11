# frozen_string_literal: true

class CreateGithubReleases < ActiveRecord::Migration[8.0]
  def change
    create_table :github_releases do |t|
      t.belongs_to :github_repository, null: false, foreign_key: { to_table: :works }
      t.string :status, null: false, default: 'queued'
      t.text :status_details
      t.string :release_tag, null: false
      t.bigint :release_id, null: false
      t.string :release_name, null: false
      t.string :zip_url, null: false
      t.datetime :published_at, null: false

      t.timestamps
      t.index :release_id
    end
  end
end
