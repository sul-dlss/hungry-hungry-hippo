# frozen_string_literal: true

Rails.application.config.after_initialize do
  # Subscriptions for CollectionsMailer
  Notifier.subscribe_mailer(event_name: Notifier::DEPOSITOR_ADDED, mailer_class: CollectionsMailer,
                            mailer_method: :invitation_to_deposit_email)
  Notifier.subscribe_mailer(event_name: Notifier::MANAGER_ADDED, mailer_class: CollectionsMailer,
                            mailer_method: :manage_access_granted_email)
end
