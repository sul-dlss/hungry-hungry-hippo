# frozen_string_literal: true

# Sends the appropriate emails when a work is accessioned.
class WorkAccessioningCompletedSubscriptionMailer
  def self.call(...)
    new(...).call
  end

  # @param [Work|Collection] object the work or collection that was accessioned
  def initialize(object:)
    @object = object
  end

  def call
    return unless object.is_a?(Work)

    users_for(work: object).each do |user|
      send_to(work: object, user:)
    end
  end

  private

  attr_reader :object

  def users_for(work:)
    users = [work.user]
    work.shares.deposit.each do |share|
      users << share.user
    end
    users.uniq
  end

  def send_to(work:, user:)
    if work.first_version?
      WorksMailer.with(work:, user:).deposited_email.deliver_later
    else
      WorksMailer.with(work:, user:).new_version_deposited_email.deliver_later
    end
  end
end
