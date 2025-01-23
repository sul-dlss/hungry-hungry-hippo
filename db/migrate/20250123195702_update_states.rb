class UpdateStates < ActiveRecord::Migration[8.0]
  def change
    change_column_default :works, :review_state, from: 'none_review', to: 'review_not_in_progress'
    change_column_default :works, :deposit_state, from: 'deposit_none', to: 'deposit_not_in_progress'
    change_column_default :collections, :deposit_state, from: 'none_deposit', to: 'deposit_not_in_progress'
    execute "UPDATE works SET review_state = 'review_not_in_progress' WHERE review_state = 'none_review'"
    execute "UPDATE works SET deposit_state = 'deposit_not_in_progress' WHERE deposit_state = 'deposit_none'"
    execute "UPDATE collections SET deposit_state = 'deposit_not_in_progress' WHERE deposit_state = 'deposit_none'"
    execute "UPDATE works SET deposit_state = 'registering_or_updating' WHERE deposit_state = 'persisting'"
    execute "UPDATE collections SET deposit_state = 'registering_or_updating' WHERE deposit_state = 'persisting'"
  end
end
