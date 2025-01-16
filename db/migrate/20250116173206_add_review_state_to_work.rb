class AddReviewStateToWork < ActiveRecord::Migration[8.0]
  def change
    add_column :works, :review_state, :string, default: 'none_review', null: false
    add_column :works, :review_rejected_reason, :string
    add_index :works, :review_state
  end
end
