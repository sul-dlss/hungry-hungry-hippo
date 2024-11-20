# frozen_string_literal: true

class WorkPolicy < ApplicationPolicy
  alias_rule :show?, :update?, :edit?, :wait?, to: :manage?

  def manage?
    record.user_id == user.id
  end
end
