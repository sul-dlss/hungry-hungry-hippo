# frozen_string_literal: true

module SubscriptionActions
  # Action that sends the appropriate emails when a collection is persisted.
  class CollectionDepositPersistCompleted
    def self.call(...)
      new(...).call
    end

    # @param [Work|Collection] object the work or collection that was persisted
    def initialize(object:)
      @object = object
    end

    def call
      return unless object.is_a?(Collection)

      return unless object.first_version?

      CollectionsMailer.with(collection: object).first_version_created_email.deliver_later
    end

    private

    attr_reader :object
  end
end
