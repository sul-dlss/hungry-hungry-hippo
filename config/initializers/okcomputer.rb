# frozen_string_literal: true

require 'okcomputer'

# /status for 'upness', e.g. for load balancer
# /status/all to show all dependencies
# /status/<name-of-check> for a specific check (e.g. for nagios warning)
OkComputer.mount_at = 'status'
OkComputer.check_in_parallel = true

# Required
OkComputer::Registry.register 'ruby_version', OkComputer::RubyVersionCheck.new

if Settings.rabbitmq.enabled
  OkComputer::Registry.register 'rabbit',
                                OkComputer::RabbitmqCheck.new(hostname: Settings.rabbitmq.hostname,
                                                              vhost: Settings.rabbitmq.vhost,
                                                              username: Settings.rabbitmq.username,
                                                              password: Settings.rabbitmq.password)
end

# A custom OkComputer status check for Globus.
# It uses the Globus user_valid? check to determine if the Globus service is healthy.
# NOTE: This does not FAIL if the status user is invalid because that still indicates that the Globus service is up
class GlobusStatusCheck < OkComputer::Check
  def check
    GlobusClient.user_valid?('dummy@stanford.edu')
  rescue StandardError => e
    mark_failure
    mark_message "Globus status check failed: #{e.message}"
  end
end

OkComputer::Registry.register 'globus', GlobusStatusCheck.new if Settings.globus.enabled
