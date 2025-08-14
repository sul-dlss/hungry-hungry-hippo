# frozen_string_literal: true

# Sends the appropriate emails when collections participants are changed.
class CollectionParticipantsChangedSubscriptionMailer
  def self.call(...)
    new(...).call
  end

  # @param [Collection] collection the collection that was changed
  def initialize(collection:, **)
    @collection = collection
  end

  def call
    return unless collection.email_when_participants_changed

    # if the collection is a first_version and has not already been saved at least once, don't send emails
    # i.e. emails are only NOT sent the very first time a brand new collection is saved
    return if collection.first_version? && collection.updated_at == collection.created_at

    managers_and_reviewers.each do |manager|
      CollectionsMailer.with(collection:, user: manager).participants_changed_email.deliver_later
    end
  end

  private

  def managers_and_reviewers
    managers = collection.managers + collection.reviewers
    managers.reject { |user| user.email_address.blank? }.uniq
  end

  attr_reader :collection
end
