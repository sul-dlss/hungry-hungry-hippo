# frozen_string_literal: true

# Base class for application policies
class ApplicationPolicy < ActionPolicy::Base
  pre_check :allow_admins

  def allow_admins
    allow! if Current.groups.include?(Settings.authorization_workgroup_names.administrators)
  end

  private

  def collection_creator?
    Current.groups.include?(Settings.authorization_workgroup_names.collection_creators)
  end
end
