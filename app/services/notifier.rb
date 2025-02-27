# frozen_string_literal: true

# Wrapper around ActiveSupport::Notifications to publish events
class Notifier
  # Events
  MANAGER_ADDED = 'manager_added'
  REVIEWER_ADDED = 'reviewer_added'
  DEPOSITOR_ADDED = 'depositor_added'

  MANAGER_REMOVED = 'manager_removed'
  REVIEWER_REMOVED = 'reviewer_removed'
  DEPOSITOR_REMOVED = 'depositor_removed'

  REVIEW_REQUESTED = 'review_requested'
  REVIEW_APPROVED = 'review_approved'
  REVIEW_REJECTED = 'review_rejected'

  DEPOSIT_PERSIST_COMPLETE = 'deposit_persist_complete'
  ACCESSIONING_COMPLETE = 'accessioning_complete'

  # Publishes an event with the given name and payload
  # @param event_name [String] the name of the event
  # @param payload [Hash] the payload to include with the event
  def self.publish(event_name, **payload)
    ActiveSupport::Notifications.instrument(event_name, **payload)
  end

  def self.subscribe_mailer(event_name:, mailer_class:, mailer_method:)
    ActiveSupport::Notifications.subscribe(event_name) do |event|
      mailer_class.with(**event.payload).send(mailer_method).deliver_later if Settings.notifications.enabled
    end
  end

  def self.subscribe_action(event_name:, action_class:)
    ActiveSupport::Notifications.subscribe(event_name) do |event|
      action_class.call(**event.payload) if Settings.notifications.enabled
    end
  end
end
