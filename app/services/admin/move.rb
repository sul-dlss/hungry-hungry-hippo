# frozen_string_literal: true

module Admin
  # Move a work to a new collection
  class Move
    def self.call(...)
      new(...).call
    end

    def initialize(work_form:, work:, collection:, version_status:, ahoy_visit:)
      @work_form = work_form
      @work = work
      @collection = collection
      @version_status = version_status
      @ahoy_visit = ahoy_visit
    end

    def call
      work_form.collection_druid = collection.druid

      work.deposit_persist! # Sets the deposit state

      update_depositors

      # Deposit if not a draft
      DepositWorkJob.perform_later(work:, work_form:, deposit: deposit?,
                                   request_review: false, current_user: Current.user, ahoy_visit:)
    end

    private

    attr_reader :ahoy_visit, :work_form, :work, :collection, :version_status

    def deposit?
      !version_status.open?
    end

    def update_depositors
      return if collection.depositors.include?(work.user)

      collection.depositors << work.user
    end
  end
end
