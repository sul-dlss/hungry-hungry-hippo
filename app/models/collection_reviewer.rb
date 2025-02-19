# frozen_string_literal: true

# Model for a join between Users and Collections for the reviewer relationship.
class CollectionReviewer < ApplicationRecord
  self.primary_key = %i[user_id collection_id]

  belongs_to :user
  belongs_to :collection

  after_create -> { Notifier.publish(Notifier::REVIEWER_ADDED, user:, collection:) }
  after_destroy -> { Notifier.publish(Notifier::REVIEWER_REMOVED, user:, collection:) }
end
