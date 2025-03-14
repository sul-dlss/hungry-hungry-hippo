# frozen_string_literal: true

class AddDepositsContactEmailToCollections < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :deposits_contact_email, :string
  end
end
