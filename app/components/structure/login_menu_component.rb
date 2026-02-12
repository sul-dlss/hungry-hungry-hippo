# frozen_string_literal: true

module Structure
  # Dropdown menu for user login/logout, used in the header
  class LoginMenuComponent < ViewComponent::Base
    def admin?
      Current.groups.include?(Settings.authorization_workgroup_names.administrators)
    end

    delegate :current_user, to: :helpers
  end
end
