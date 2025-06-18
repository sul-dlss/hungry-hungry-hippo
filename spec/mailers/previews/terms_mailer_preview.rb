# frozen_string_literal: true

# Preview with http://localhost:3000/rails/mailers/terms_mailer/
class TermsMailerPreview < ActionMailer::Preview
  def reminder_email
    TermsMailer.with(user: User.first).reminder_email
  end
end
