# frozen_string_literal: true

# Presenter for the status of a work or collection.
# Wraps the status returned from DSA.
class StatusPresenter
  # @param [Dor::Services::Client::ObjectVersion::VersionStatus, nil] status status or nil
  def initialize(status: nil)
    @status = status
  end

  def status_message
    return 'Saving' if status.nil? # No druid yet, so H3 is depositing.
    return 'Draft - Not deposited' if status.open? && status.version == 1
    return 'New version in draft' if status.open?
    return 'Depositing' if status.accessioning?

    'Deposited'
  end

  def editable?
    status.openable? || status.open?
  end

  private

  attr_reader :status
end
