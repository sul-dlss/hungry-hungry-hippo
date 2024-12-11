# frozen_string_literal: true

module MissionControl
  module Jobs
    class QueuesPolicy < ActionPolicy::Base
      alias_rule :show?, :index?, to: :manage?

      def manage?
        ::Current.groups.include?(
          Settings.authorization_workgroup_names.administrators
        )
      end
    end
  end
end
