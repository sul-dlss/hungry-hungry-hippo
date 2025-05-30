# frozen_string_literal: true

class GlobusPolicy < ApplicationPolicy
  alias_rule :new?, :create?, :uploading?, :cancel?, to: :manage?

  def manage?
    # Record is a Content
    record.user_id == user.id
  end
end
