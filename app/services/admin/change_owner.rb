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
      @collection = work.collection
      @owner = owner
      @version_status = version_status
    end

    def call
      work.user = owner
      work.deposit_persist! # Sets the deposit state

      update_depositors

      # Deposit if not a draft
      DepositWorkJob.perform_later(work:, work_form:, deposit: deposit?,
                                   request_review: false, current_user: owner)
    end

    private

    attr_reader :collection, :owner, :work, :work_form, :version_status

    def deposit?
      !version_status.open?
    end

    def update_depositors
      return if collection.depositors.include?(work.user)

      collection.depositors << work.user
    end
  end
end
