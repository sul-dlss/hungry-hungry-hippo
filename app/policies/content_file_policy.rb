# frozen_string_literal: true

class ContentFilePolicy < ApplicationPolicy
  alias_rule :show?, :update?, :edit?, :destroy?, :download?, to: :manage?

  def manage?
    record.content.user_id == user.id
  end
end
