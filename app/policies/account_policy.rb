# frozen_string_literal: true

# Authorization policy for lookup of accounts
class AccountPolicy < ApplicationPolicy
  def search?
    collection_creator? || manages_any_collection?
  end

  private

  def manages_any_collection?
    user.manages.exists?
  end
end
