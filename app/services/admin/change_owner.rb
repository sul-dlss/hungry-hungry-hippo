# frozen_string_literal: true

module Admin
  # Change ownership of a work
  class ChangeOwner
    def self.call(...)
      new(...).call
    end

    def initialize(work_form:, work:, owner:, version_status:)
      @work_form = work_form
      @work = work
      @owner = owner
      @version_status = version_status
    end

    def call
      work.user = owner
      work.deposit_persist! # Sets the deposit state

      # Deposit if not a draft
      DepositWorkJob.perform_later(work:, work_form:, deposit: deposit?,
                                   request_review: false, current_user: owner)
    end

    private

    attr_reader :work_form, :work, :owner, :version_status

    def deposit?
      !version_status.open?
    end
  end
end
