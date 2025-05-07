# frozen_string_literal: true

class AddGlobusToContent < ActiveRecord::Migration[8.0]
  def change
    add_column :contents, :globus_state, :string, default: 'globus_not_in_progress'
    add_reference :contents, :work, foreign_key: true, index: true
  end
end
