# frozen_string_literal: true

class SharePolicy < ApplicationPolicy
  alias_rule :new?, :create?, to: :manage?

  def manage?
    record.user_id == user.id
  end
end
