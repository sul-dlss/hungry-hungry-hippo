# frozen_string_literal: true

class CollectionPolicy < ApplicationPolicy
  alias_rule :show?, :update?, :edit?, :wait?, :destroy?, to: :manage?

  def manage?
    collection_manager? || record.user_id == user.id
  end

  def new?
    collection_creator?
  end

  def create?
    collection_creator?
  end

  # TODO: Add a rule for collection managers & depositors
  # manage? will be based on the managers added to a collection
  # display? will be based on the depositors added to a collection
  # alias_rule :show?, :update?, :edit?, :wait?, to: :manage?

  def collection_manager?
    record.managers.include?(user)
  end
end
