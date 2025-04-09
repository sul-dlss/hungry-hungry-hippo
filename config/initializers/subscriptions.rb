# frozen_string_literal: true

Rails.application.config.after_initialize do # rubocop:disable Metrics/BlockLength
  # Subscriptions for CollectionsMailer
  # Depositor change notifications
  Notifier.subscribe(event_name: Notifier::DEPOSITOR_ADDED) do |payload|
    CollectionsMailer.with(**payload).invitation_to_deposit_email.deliver_later
  end
  Notifier.subscribe(event_name: Notifier::DEPOSITOR_REMOVED) do |payload|
    CollectionsMailer.with(**payload).deposit_access_removed_email.deliver_later
  end
  Notifier.subscribe(event_name: Notifier::DEPOSITOR_ADDED) do |payload|
    CollectionsMailer.with(**payload).participants_changed_email.deliver_later
  end
  Notifier.subscribe(event_name: Notifier::DEPOSITOR_REMOVED) do |payload|
    CollectionsMailer.with(**payload).participants_changed_email.deliver_later
  end
  Notifier.subscribe(event_name: Notifier::DEPOSIT_PERSIST_COMPLETE) do |payload|
    CollectionDepositPersistCompletedSubscriptionMailer.call(**payload)
  end

  # Manager change notifications
  Notifier.subscribe(event_name: Notifier::MANAGER_ADDED) do |payload|
    CollectionsMailer.with(**payload).manage_access_granted_email.deliver_later
  end
  Notifier.subscribe(event_name: Notifier::MANAGER_ADDED) do |payload|
    CollectionsMailer.with(**payload).participants_changed_email.deliver_later
  end
  Notifier.subscribe(event_name: Notifier::MANAGER_REMOVED) do |payload|
    CollectionsMailer.with(**payload).participants_changed_email.deliver_later
  end

  # Reviewer change notifications
  Notifier.subscribe(event_name: Notifier::REVIEWER_ADDED) do |payload|
    CollectionsMailer.with(**payload).review_access_granted_email.deliver_later
  end
  Notifier.subscribe(event_name: Notifier::REVIEWER_ADDED) do |payload|
    CollectionsMailer.with(**payload).participants_changed_email.deliver_later
  end
  Notifier.subscribe(event_name: Notifier::REVIEWER_REMOVED) do |payload|
    CollectionsMailer.with(**payload).participants_changed_email.deliver_later
  end

  # Subscriptions for ReviewsMailer
  Notifier.subscribe(event_name: Notifier::REVIEW_REQUESTED) do |payload|
    ReviewsMailer.with(**payload).submitted_email.deliver_later
  end
  Notifier.subscribe(event_name: Notifier::REVIEW_REJECTED) do |payload|
    ReviewsMailer.with(**payload).rejected_email.deliver_later
  end
  Notifier.subscribe(event_name: Notifier::REVIEW_APPROVED) do |payload|
    ReviewsMailer.with(**payload).approved_email.deliver_later
  end
  Notifier.subscribe(event_name: Notifier::REVIEW_REQUESTED) do |payload|
    ReviewRequestSubscriptionMailer.call(**payload)
  end

  # Subscriptions for WorksMailer
  Notifier.subscribe(event_name: Notifier::ACCESSIONING_STARTED) do |payload|
    WorkAccessioningStartedSubscriptionMailer.call(**payload)
  end
  Notifier.subscribe(event_name: Notifier::ACCESSIONING_COMPLETE) do |payload|
    WorkAccessioningCompletedSubscriptionMailer.call(**payload)
  end
end
