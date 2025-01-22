class AddDepositStateToCollection < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :deposit_state, :string, default: 'deposit_none', null: false
    add_index :collections, :deposit_state
    remove_column :collections, :deposit_job_started_at
  end
end
