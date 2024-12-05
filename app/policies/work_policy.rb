# frozen_string_literal: true

class WorkPolicy < ApplicationPolicy
  alias_rule :new?, :create?, :show?, :update?, :edit?, :wait?, to: :manage?

  def manage?
    record.user_id == user.id
  end
end
