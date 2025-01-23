# frozen_string_literal: true

Rails.application.config.after_initialize do
  # Subscriptions for CollectionsMailer
  Notifier.subscribe_mailer(event_name: Notifier::DEPOSITOR_ADDED, mailer_class: CollectionsMailer,
                            mailer_method: :invitation_to_deposit_email)
  Notifier.subscribe_mailer(event_name: Notifier::MANAGER_ADDED, mailer_class: CollectionsMailer,
                            mailer_method: :manage_access_granted_email)
  Notifier.subscribe_mailer(event_name: Notifier::REVIEWER_ADDED, mailer_class: CollectionsMailer,
                            mailer_method: :review_access_granted_email)

  # Subscriptions for ReviewsMailer
  Notifier.subscribe_mailer(event_name: Notifier::REVIEW_REQUESTED, mailer_class: ReviewsMailer,
                            mailer_method: :submitted_email)
  Notifier.subscribe_mailer(event_name: Notifier::REVIEW_REJECTED, mailer_class: ReviewsMailer,
                            mailer_method: :rejected_email)
  Notifier.subscribe_mailer(event_name: Notifier::REVIEW_APPROVED, mailer_class: ReviewsMailer,
                            mailer_method: :approved_email)
  Notifier.subscribe_action(event_name: Notifier::REVIEW_REQUESTED,
                            action_class: SubscriptionActions::ReviewRequest)

  # Subscriptions for WorksMailer
  Notifier.subscribe_action(event_name: Notifier::ACCESSIONING_COMPLETE,
                            action_class: SubscriptionActions::WorkAccessioningCompleted)
end
