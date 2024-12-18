# frozen_string_literal: true

class ContentFilePolicy < ApplicationPolicy
  alias_rule :show?, :update?, :edit?, :destroy?, to: :manage?

  def manage?
    return true if admin?

    record.content.user_id == user.id
  end
end
