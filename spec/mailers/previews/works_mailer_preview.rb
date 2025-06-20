# frozen_string_literal: true

# Preview with http://localhost:3000/rails/mailers/works_mailer/
class WorksMailerPreview < ActionMailer::Preview
  def deposited_email
    WorksMailer.with(work: Work.first).deposited_email
  end

  # For when the accessioning of subsequent version is completed.
  def new_version_deposited_email
    WorksMailer.with(work: Work.first).new_version_deposited_email
  end

  def managers_depositing_email
    WorksMailer.with(work: Work.first).managers_depositing_email
  end

  def ownership_changed_email
    WorksMailer.with(work: Work.first).ownership_changed_email
  end

  def share_added_email
    WorksMailer.with(work: Work.first, permission: 'view',
                     user_shared_with: User.new(first_name: 'Shared', name: 'With',
                                                email_address: 'test@test.com')).share_added_email
  end
end
