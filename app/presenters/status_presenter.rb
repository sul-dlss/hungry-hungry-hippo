# frozen_string_literal: true

# Presenter for the status of a work.
# Wraps the status returned from DSA.
class StatusPresenter
  # @param [Dor::Services::Client::ObjectVersion::VersionStatus] status the status of the work
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

  private

  attr_reader :status
end
