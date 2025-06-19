# frozen_string_literal: true

class LastEmailSent < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :terms_reminder_email_last_sent_at, :datetime
  end
end
