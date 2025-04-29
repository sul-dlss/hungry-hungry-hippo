# frozen_string_literal: true

# Sends the appropriate emails when accessioning is started for a collection.
class CollectionAccessioningStartedSubscriptionMailer
  def self.call(...)
    new(...).call
  end

  # @param [Work|Collection] object the work or collection that was persisted
  def initialize(object:, **args) # rubocop:disable Lint/UnusedMethodArgument
    @object = object
    # Note that other args are passed to this subscription, but are not used.
  end

  def call
    return unless object.is_a?(Collection)

    return unless object.first_version?

    CollectionsMailer.with(collection: object).first_version_created_email.deliver_later
  end

  private

  attr_reader :object
end
