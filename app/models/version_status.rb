# frozen_string_literal: true

# Model for the version status of a work or collection.
# Wraps the status returned from DSA.
class VersionStatus
  # Nil status for when there is no status yet since H3 is still depositing.
  class NilStatus
    def status_message
      'Saving'
    end

    def draft?
      false
    end
  end

  # @param [Dor::Services::Client::ObjectVersion::VersionStatus] status status
  def initialize(status:)
    @status = status
  end

  def status_message
    return 'Draft - Not deposited' if status.open? && status.version == 1
    return 'New version in draft' if status.open?
    return 'Depositing' if status.accessioning?

    'Deposited'
  end

  def editable?
    status.openable? || status.open?
  end

  def draft?
    status.open?
  end

  def first_draft?
    status.open? && status.version == 1
  end

  def discardable?
    # SDR does not consider version 1 of an object to be discardable. (It can be purged, however.)
    if status.version == 1
      status.open?
    else
      status.discardable?
    end
  end

  delegate :open?, :openable?, :version, to: :status

  private

  attr_reader :status
end
