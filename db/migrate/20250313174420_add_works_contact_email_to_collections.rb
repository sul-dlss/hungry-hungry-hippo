# frozen_string_literal: true

class AddWorksContactEmailToCollections < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :works_contact_email, :string
  end
end
