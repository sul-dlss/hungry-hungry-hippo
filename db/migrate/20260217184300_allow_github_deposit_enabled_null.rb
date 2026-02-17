# frozen_string_literal: true

class AllowGithubDepositEnabledNull < ActiveRecord::Migration[8.0]
  def change
    change_column_null :works, :github_deposit_enabled, true
    change_column_default :works, :github_deposit_enabled, from: false, to: nil
  end
end
