# frozen_string_literal: true

# Defines the deposit states for an object.
module DepositStateMachine
  extend ActiveSupport::Concern

  included do
    # In general, the version status should be used for the status of an object.
    # However, deposit_state is used for very specific purposes.
    # In particular, registering_or_updating is used to indicate that the DepositWorkJob is queued / running.
    # Accessioning is used to track if the accessioning of an object originated with H3.
    # That way when the rabbitMQ message for the end of the accessioning is received,
    # it can be determined if H3 users should be notified.
    state_machine :deposit_state, initial: :deposit_not_in_progress do
      event :deposit_persist do
        transition deposit_not_in_progress: :deposit_registering_or_updating
      end

      # As part of the deposit job, accessioning may or may not be started.
      # If accessioning is started, the accessioning state is set.
      # If accessioning is not started, the state is set to deposit_not_in_progress.
      event :deposit_persist_complete do
        transition deposit_registering_or_updating: :deposit_not_in_progress
      end

      event :accession do
        transition deposit_registering_or_updating: :accessioning
      end

      event :accession_complete do
        transition accessioning: :deposit_not_in_progress
      end

      before_transition deposit_registering_or_updating: any do |object|
        Notifier.publish(Notifier::DEPOSIT_PERSIST_COMPLETE, object:)
      end

      before_transition accessioning: :deposit_not_in_progress do |object|
        Notifier.publish(Notifier::ACCESSIONING_COMPLETE, object:)
      end
    end
  end
end
