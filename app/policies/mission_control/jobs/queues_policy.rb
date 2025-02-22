# frozen_string_literal: true

module MissionControl
  module Jobs
    class QueuesPolicy < ActionPolicy::Base
      # @note These two rule macros effectively forward all rules to #manage?
      # @see https://actionpolicy.evilmartians.io/#/aliases?id=default-rule
      default_rule :manage?
      alias_rule :index?, :create?, :new?, to: :manage?

      def manage?
        ::Current.groups.include?(
          Settings.authorization_workgroup_names.administrators
        )
      end
    end
  end
end
