# frozen_string_literal: true

class DashboardPolicy < ApplicationPolicy
  def show?
    collection_creator? || user.depositor_for.any? || user.reviewer_for.any? || user.manages.any? || user.shares.any?
  end
end
