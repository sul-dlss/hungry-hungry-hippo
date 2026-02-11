# frozen_string_literal: true

# Model for the version status of a work or collection.
# Wraps the status returned from DSA.
class VersionStatus
  # Nil status for when there is no status yet since H3 is still depositing.
  class NilStatus
    def status_message = 'Saving'

    def draft? = false

    def editable? = false

    def discardable? = false
  end

  # @param [Dor::Services::Client::ObjectVersion::VersionStatus] status status
  def initialize(status:)
    @status = status
  end

  def status_message
    return 'Draft - Not deposited' if first_draft?
    return 'New version in draft' if status.open?
    return 'Depositing' if status.accessioning?

    'Deposited'
  end

  def editable?
    openable? || open?
  end

  def draft?
    open?
  end

  def first_draft?
    open? && first_version?
  end

  def first_version?
    version == 1
  end

  def discardable?
    # SDR does not consider version 1 of an object to be discardable. (It can be purged, however.)
    if first_version?
      open?
    else
      status.discardable?
    end
  end

  delegate :open?, :openable?, :accessioning?, :closeable?, :version, :version_description, to: :status

  private

  attr_reader :status
end
