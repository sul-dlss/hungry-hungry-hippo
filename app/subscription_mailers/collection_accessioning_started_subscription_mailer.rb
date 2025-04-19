# frozen_string_literal: true

# Sends the appropriate emails when accessioning is started for a collection.
class CollectionAccessioningStartedSubscriptionMailer
  def self.call(...)
    new(...).call
  end

  # @param [Work|Collection] object the work or collection that was persisted
  # @param [User] current_user the user that performed the action
  def initialize(object:, current_user:) # rubocop:disable Lint/UnusedMethodArgument
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
