# frozen_string_literal: true

module Sdr
  # Methods for interfacing with the workflow service
  class Workflow
    class Error < StandardError; end

    # @param [String] druid
    # @param [String] workflow_name
    # @param [Integer] version (1)
    # @param [String] priority ('default') determines the relative priority used for the workflow.
    #                                      Value may be 'low' or 'default'
    # @raise [Error] if there is an error creating the workflow
    def self.create_unless_exists(druid, workflow_name, version: 1, priority: 'default')
      return unless workflow_client.workflow(pid: druid, workflow_name:).empty?

      workflow_client.create_workflow_by_name(druid, workflow_name, version:, lane_id: priority)
    rescue Dor::WorkflowException => e
      raise Error, "Creating workflow failed: #{e.message}"
    end

    def self.workflow_client
      Dor::Workflow::Client.new(url: Settings.workflow.url,
                                logger: Rails.logger,
                                timeout: 60)
    end
  end
end
