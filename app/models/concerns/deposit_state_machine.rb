# frozen_string_literal: true

# Defines the deposit states for an object.
module DepositStateMachine
  extend ActiveSupport::Concern

  included do
    # In general, the version status should be used for the status of an object.
    # However, deposit_state is used for very specific purposes.
    # In particular, persisting is used to indicate that the DepositWorkJob is queued / running.
    # Accessioning is used to track if the accessioning of an object originated with H3.
    # That way when the rabbitMQ message for the end of the accessioning is received,
    # it can be determined if H3 users should be notified.
    state_machine :deposit_state, initial: :deposit_none do
      event :deposit_persist do
        transition deposit_none: :deposit_persisting
      end

      # As part of the deposit job, accessioning may or may not be started.
      # If accessioning is started, the accessioning state is set.
      # If accessioning is not started, the state is set to none.
      event :deposit_persist_complete do
        transition deposit_persisting: :deposit_none
      end

      event :accession do
        transition deposit_persisting: :accessioning
      end

      event :accession_complete do
        transition accessioning: :deposit_none
      end

      before_transition accessioning: :deposit_none do |object|
        Notifier.publish(Notifier::ACCESSIONING_COMPLETE, object:)
      end
    end
  end
end
