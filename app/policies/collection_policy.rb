# frozen_string_literal: true

class CollectionPolicy < ApplicationPolicy
  alias_rule :update?, :edit?, :wait?, :destroy?, to: :manage?
  alias_rule :works?, to: :show?

  def show?
    collection_depositor? || manage?
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
end
