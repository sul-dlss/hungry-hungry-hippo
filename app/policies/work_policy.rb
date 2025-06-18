# frozen_string_literal: true

class WorkPolicy < ApplicationPolicy
  alias_rule :update?, :edit?, to: :manage?
  alias_rule :wait?, :history?, to: :show?
  alias_rule :new?, to: :create?

  def create?
    # Record is a Collection here.
    record.user_id == user.id || collection_manager? || collection_owner? || collection_depositor?
  end

  def manage?
    record.user_id == user.id || collection_manager? || collection_owner? ||
      shared?(permissions: [Share::VIEW_EDIT_PERMISSION, Share::VIEW_EDIT_DEPOSIT_PERMISSION])
  end

  def deposit?
    return create? if record.is_a? Collection

    record.user_id == user.id || collection_manager? || collection_owner? || collection_reviewer? ||
      shared?(permissions: [Share::VIEW_EDIT_DEPOSIT_PERMISSION])
  end

  def destroy?
    record.user_id == user.id || collection_manager? || collection_owner?
  end

  def show?
    manage? || collection_reviewer? ||
      shared?(permissions: [Share::VIEW_PERMISSION, Share::VIEW_EDIT_PERMISSION, Share::VIEW_EDIT_DEPOSIT_PERMISSION])
  end

  def review?
    collection_reviewer? || collection_manager?
  end

  def edit_pending_review?
    collection_manager?
  end

  relation_scope(:collection) do |relation, collection:|
    next relation if admin? || user.roles_for(collection:).intersect?(%w[manager reviewer])

    relation.where(user:).left_outer_joins(:shares).or(
      relation.left_outer_joins(:shares)
            # This is any share, not a specific permission
            .where(shares: { user: })
    )
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

  def shared?(permissions: [])
    record.shares.exists?(user_id: user.id, permission: permissions)
  end
end
