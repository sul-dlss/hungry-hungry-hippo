# frozen_string_literal: true

# This class is used to store the current variables (e.g., user) in a thread-safe way.
# This obviates the need to pass these variables around as arguments, e.g., to view components.
# They can be accessed with Current.user, etc.
class Current < ActiveSupport::CurrentAttributes
  attribute :user
  attribute :groups
end
