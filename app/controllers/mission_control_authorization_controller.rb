# frozen_string_literal: true

# Controller for authorizing access to MissionControl Jobs
class MissionControlAuthorizationController < ApplicationController
  before_action do |_controller|
    authorize(%i[mission_control jobs queues], :manage?)
  end
end
