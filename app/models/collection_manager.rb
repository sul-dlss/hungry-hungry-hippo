# frozen_string_literal: true

# Model for a join between Users and Collections for the manager relationship.
class CollectionManager < ApplicationRecord
  self.primary_key = %i[user_id collection_id]

  belongs_to :user
  belongs_to :collection

  after_create -> { Notifier.publish(Notifier::MANAGER_ADDED, user:, collection:) }
end
