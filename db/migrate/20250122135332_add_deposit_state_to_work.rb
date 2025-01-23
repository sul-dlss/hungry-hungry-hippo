class AddDepositStateToWork < ActiveRecord::Migration[8.0]
  def change
    add_column :works, :deposit_state, :string, default: 'deposit_none', null: false
    add_index :works, :deposit_state
    remove_column :works, :deposit_job_started_at
  end
end
