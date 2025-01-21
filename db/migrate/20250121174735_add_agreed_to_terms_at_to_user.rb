class AddAgreedToTermsAtToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :agreed_to_terms_at, :datetime
  end
end
