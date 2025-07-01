# frozen_string_literal: true

# Sends the appropriate emails when a work ownership is changed.
class WorkOwnershipChangedSubscriptionMailer
  def self.call(...)
    new(...).call
  end

  # @param [Work] object the work that was changed
  # @param [User] current_user the user who made the change
  def initialize(object:, current_user:)
    @object = object
    @current_user = current_user
  end

  def call
    return unless object.is_a?(Work)

    [current_user, object.user].uniq.each do |user|
      WorksMailer.with(work: object, user:).ownership_changed_email.deliver_later
    end
  end

  private

  attr_reader :object, :current_user
end
