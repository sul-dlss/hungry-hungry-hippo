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
    work = Work.first
    shared_with = User.new(first_name: 'SharedWith', name: 'User', email_address: 'shared_with@test.com')
    share = Share.new(user: shared_with, work:, permission: Share::VIEW_PERMISSION)
    WorksMailer.with(share:, work:).share_added_email
  end
end
