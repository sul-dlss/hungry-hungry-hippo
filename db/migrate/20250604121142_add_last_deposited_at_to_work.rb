# frozen_string_literal: true

class AddLastDepositedAtToWork < ActiveRecord::Migration[8.0]
  def change
    add_column :works, :last_deposited_at, :datetime
  end
end
