class AddDepositJobStartedToCollections < ActiveRecord::Migration[8.0]
  def change
    change_column_null :collections, :druid, true
    add_column :collections, :deposit_job_started_at, :datetime
  end
end
