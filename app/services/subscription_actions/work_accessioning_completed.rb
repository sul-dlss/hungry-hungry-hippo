# frozen_string_literal: true

module SubscriptionActions
  # Action that sends the appropriate emails when a work is accessioned.
  class WorkAccessioningCompleted
    def self.call(...)
      new(...).call
    end

    # @param [Work|Collection] object the work or collection that was accessioned
    def initialize(object:)
      @object = object
    end

    def call
      return unless object.is_a?(Work)

      if object.first_version?
        WorksMailer.with(work: object).deposited_email.deliver_later
      else
        WorksMailer.with(work: object).new_version_deposited_email.deliver_later
      end
    end

    private

    attr_reader :object
  end
end
