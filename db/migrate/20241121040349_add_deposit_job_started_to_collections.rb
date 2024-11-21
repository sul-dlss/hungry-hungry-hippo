class AddDepositJobStartedToCollections < ActiveRecord::Migration[8.0]
  def change
    add_column :collections, :deposit_job_started_at, :datetime
    change_column_null :collections, :druid, true
  end
end
