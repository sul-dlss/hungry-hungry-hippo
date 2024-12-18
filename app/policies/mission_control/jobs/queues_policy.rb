# frozen_string_literal: true

module MissionControl
  module Jobs
    class QueuesPolicy < ApplicationPolicy
      def manage?
        admin?
      end
    end
  end
end
