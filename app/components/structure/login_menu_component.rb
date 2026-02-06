# frozen_string_literal: true

module Structure
  # Dropdown menu for user login/logout, used in the header
  class LoginMenuComponent < ViewComponent::Base
    def admin?
      Current.groups.include?(Settings.authorization_workgroup_names.administrators)
    end

    def github_connection?
      return false unless Settings.github.enabled

      current_user.connected_to_github? || current_user.depositor_for_any_github_deposit_enabled_collections?
    end

    delegate :current_user, to: :helpers
  end
end
