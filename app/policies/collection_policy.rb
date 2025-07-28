# frozen_string_literal: true

class CollectionPolicy < ApplicationPolicy
  alias_rule :update?, :edit?, :destroy?, to: :manage?
  alias_rule :works?, :history?, to: :show?

  def show?
    collection_depositor? || manage? || collection_reviewer?
  end

  def manage?
    collection_manager?
  end

  def new?
    collection_creator?
  end

  def create?
    collection_creator?
  end

  def review?
    collection_reviewer? || collection_manager?
  end

  def wait?
    # When creating, additional collection roles other than owner may not have been assigned yet.
    collection_manager? || owner?
  end

  private

  def collection_manager?
    record.managers.include?(user)
  end

  def collection_depositor?
    record.depositors.include?(user)
  end

  def collection_reviewer?
    record.reviewers.include?(user)
  end

  def owner?
    record.user == user
  end
end
