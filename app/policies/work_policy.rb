# frozen_string_literal: true

class WorkPolicy < ApplicationPolicy
  alias_rule :show?, :update?, :edit?, :wait?, :destroy?, to: :manage?

  def manage?
    record.user_id == user.id || collection_manager? || collection_owner?
  end

  def new?
    collection_depositor? || manage?
  end

  def create?
    collection_depositor? || manage?
  end

  def collection_manager?
    return record.managers.include?(user) if record.is_a? Collection

    record.collection.managers.include?(user)
  end

  def collection_depositor?
    return record.depositors.include?(user) if record.is_a? Collection

    record.collection.depositors.include?(user)
  end

  def collection_owner?
    record.collection.user_id == user.id if record.is_a? Work
  end
end
