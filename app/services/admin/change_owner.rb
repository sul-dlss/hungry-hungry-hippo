# frozen_string_literal: true

module Admin
  # Change ownership of a work
  class ChangeOwner
    def self.call(...)
      new(...).call
    end

    def initialize(work_form:, work:, user:, admin_user:, ahoy_visit:)
      @work_form = work_form
      @work = work
      @collection = work.collection
      @user = user
      @admin_user = admin_user
      @ahoy_visit = ahoy_visit
    end

    # rubocop:disable Metrics/AbcSize
    def call
      # user == the requested new owner of the work submitted by the admin
      # work.user == the current owner of the work
      # admin_user = the logged in admin performing the action
      Sdr::Event.create(druid: work.druid,
                        type: 'h3_owner_changed',
                        data: {
                          who: admin_user.sunetid,
                          description: "Changed owner from #{work.user.sunetid} to #{user.sunetid}"
                        })

      work.user = user
      work.deposit_persist! # Sets the deposit state

      update_depositors

      Notifier.publish(Notifier::OWNERSHIP_CHANGED, work:, user:)

      # Deposit if not a draft
      DepositWorkJob.perform_later(work:, work_form:, deposit: deposit?,
                                   request_review: false, current_user: user, ahoy_visit:)
    end
    # rubocop:enable Metrics/AbcSize

    private

    attr_reader :collection, :user, :work, :work_form, :admin_user, :ahoy_visit

    def version_status
      @version_status ||= Sdr::Repository.status(druid: work.druid)
    end

    def deposit?
      !version_status.open?
    end

    def update_depositors
      return if collection.depositors.include?(work.user)

      collection.depositors << work.user
    end
  end
end
