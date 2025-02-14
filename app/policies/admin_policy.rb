# frozen_string_literal: true

class AdminPolicy < ApplicationPolicy
  default_rule :manage?
  alias_rule :index?, :create?, :new?, to: :manage?

  def manage?
    false # Admins are allowed by precheck
  end
end
