# frozen_string_literal: true

# Sends the appropriate emails when a work ownership is changed.
class WorkOwnershipChangedSubscriptionMailer
  def self.call(...)
    new(...).call
  end

  # @param [Work|Collection] object the work or collection that was accessioned
  # @param [User] current_user the user who started the accessioning
  def initialize(object:, current_user:)
    @object = object
    @current_user = current_user
  end

  def call
    return unless object.is_a?(Work)

    WorksMailer.with(work: object, current_user:).ownership_changed_email.deliver_later
  end

  private

  attr_reader :object, :current_user
end
