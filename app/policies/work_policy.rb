# frozen_string_literal: true

class WorkPolicy < ApplicationPolicy
  alias_rule :update?, :edit?, :destroy?, to: :manage?
  alias_rule :wait?, :history?, to: :show?
  alias_rule :new?, to: :create?

  def create?
    manage? || collection_depositor?
  end

  def manage?
    record.user_id == user.id || collection_manager? || collection_owner?
  end

  def show?
    manage? || collection_reviewer?
  end

  def review?
    collection_reviewer? || collection_manager?
  end

  def edit_pending_review?
    collection_manager?
  end

  relation_scope(:collection) do |relation, collection:|
    next relation if admin? || user.roles_for(collection:).intersect?(%w[manager reviewer])

    relation.where(user:)
  end

  private

  def collection_manager?
    return record.managers.include?(user) if record.is_a? Collection

    record.collection.managers.include?(user)
  end

  def collection_depositor?
    # NOTE: `record` should always be a Collection here
    record.depositors.include?(user)
  end

  def collection_owner?
    record.collection.user_id == user.id if record.is_a? Work
  end

  def collection_reviewer?
    record.collection.reviewers.include?(user)
  end
end
