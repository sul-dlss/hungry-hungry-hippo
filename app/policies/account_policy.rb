# frozen_string_literal: true

# Authorization policy for lookup of accounts
class AccountPolicy < ApplicationPolicy
  def search?
    collection_creator? || manages_any_collection? || owns_any_work?
  end

  private

  def manages_any_collection?
    user.manages.exists?
  end

  def owns_any_work?
    user.works.exists?
  end
end
