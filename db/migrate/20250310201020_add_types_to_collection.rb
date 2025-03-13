# frozen_string_literal: true

class AddTypesToCollection < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :work_type, :string
    add_column :collections, :work_subtypes, :string, array: true, default: []
  end
end
