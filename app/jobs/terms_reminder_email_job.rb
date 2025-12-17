# frozen_string_literal: true

# Send an email to every depositor who agreed to the terms of acceptance or received an email > 1 year ago
# This job is run each day automatically via a cron job setup via whenever gem in schedule.rb
# Running daily means there should not be too many emails sent at a time (i.e. since users agree to
# the terms of deposit over time as they first start using H3, the number of users surpassing a
# year on any given day should be small).
class TermsReminderEmailJob < RetriableJob
  def perform
    users = User.where(terms_reminder_email_last_sent_at: ...1.year.ago)
                .or(User.where(agreed_to_terms_at: ...1.year.ago, terms_reminder_email_last_sent_at: nil))
    users.each do |user|
      TermsMailer.with(user:).reminder_email.deliver_now
      user.update(terms_reminder_email_last_sent_at: Time.zone.now)
    end
  end
end
