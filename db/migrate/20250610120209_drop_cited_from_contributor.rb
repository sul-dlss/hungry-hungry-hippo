# frozen_string_literal: true

class DropCitedFromContributor < ActiveRecord::Migration[8.0]
  def change
    # Remove the 'cited' column from the 'contributors' table
    remove_column :contributors, :cited, :boolean, default: false, null: false
  end
end
