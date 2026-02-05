# frozen_string_literal: true

class AddCollectionSettings < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :github_deposit_enabled, :boolean, null: false, default: false
    add_column :collections, :article_deposit_enabled, :boolean, null: false, default: false
  end
end
