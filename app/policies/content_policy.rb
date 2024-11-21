# frozen_string_literal: true

class ContentPolicy < ApplicationPolicy
  alias_rule :show?, :update?, :edit?, to: :manage?

  def manage?
    record.user_id == user.id
  end
end
