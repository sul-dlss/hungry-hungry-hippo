# frozen_string_literal: true

module Sdr
  # Service to interact with SDR.
  class Repository
    class Error < StandardError; end
    class NotFoundResponse < Error; end

    # @param [String] druid the druid of the object
    # @return [Cocina::Models::DROWithMetadata] the returned model
    # @raise [Error] if there is an error retrieving the object
    # @raise [NotFoundResponse] if the object is not found
    def self.find(druid:)
      Dor::Services::Client.object(druid).find
    rescue Dor::Services::Client::NotFoundResponse
      raise NotFoundResponse, "Object not found: #{druid}"
    end

    # @param [String] druid the druid of the object
    # @return [VersionStatus]
    def self.status(druid:)
      VersionStatus.new(status: Dor::Services::Client.object(druid).version.status)
    rescue Dor::Services::Client::NotFoundResponse
      raise NotFoundResponse, "Object not found: #{druid}"
    end

    # @param [String] druid the druid of the object
    # @return [Integer] the head user version or 1 as default
    def self.latest_user_version(druid:)
      Dor::Services::Client.object(druid).user_version.inventory.find(&:head)&.userVersion || 1
    rescue Dor::Services::Client::NotFoundResponse
      raise NotFoundResponse, "Object not found: #{druid}"
    end

    # @param [Array<String>] druids the druids of the objects
    # @return [Hash<String,VersionStatus>] map of druid to status
    def self.statuses(druids:)
      return {} if druids.empty?

      Dor::Services::Client.objects.statuses(object_ids: druids).transform_values do |status|
        VersionStatus.new(status:)
      end
    end

    # @param [Cocina::Models::RequestDRO] cocina_object
    # @param [Boolean] assign_doi true to assign a DOI; otherwise, false
    # @param [String] user_name the sunetid of the user performing the action
    # @return [Cocina::Models::DRO] the registered cocina object
    # @raise [Error] if there is an error depositing the work
    def self.register(cocina_object:, user_name:, assign_doi: false)
      response_cocina_object = Dor::Services::Client.objects.register(params: cocina_object, assign_doi:,
                                                                      user_name:)

      # Create workflow destroys existing steps if called again, so need to check if already created.
      Sdr::Workflow.create_unless_exists(response_cocina_object.externalIdentifier, 'registrationWF', version: 1)
      response_cocina_object
    rescue Dor::Services::Client::Error, Sdr::Workflow::Error => e
      raise Error, "Registration failed: #{e.message}"
    end

    # @param [String] druid the druid of the object
    # @param [boolean] new_user_version true to create a new user version; otherwise, false
    # @param [String,nil] version_description the description of the version or nil to leave unchanged
    # @raise [Error] if there is an error initiating accession
    def self.accession(druid:, version_description: nil, new_user_version: false)
      # Close the version, which will also start accessioning
      # user_versions = mode for handling user versioning.
      # Setting to update_if_existing (the default in DSA) for now.
      Dor::Services::Client.object(druid)
                           .version.close(user_versions: new_user_version ? 'new' : 'update_if_existing',
                                          user_name: Current.user.sunetid, description: version_description)
    rescue Dor::Services::Client::Error => e
      raise Error, "Initiating accession failed: #{e.message}"
    end

    # @param [Cocina::Models::DRO] cocina_object
    # @param [String] version_description the description of the version
    # @param [String] user_name the sunetid of the user performing the action
    # @param [VersionStatus] status optional status of the object to avoid a redundant status call
    # @raise [Error] if there is an error opening the object
    # @return [Cocina::Models::DRO] the updated cocina object
    def self.open_if_needed(cocina_object:, user_name:, version_description: 'Update', status: nil)
      status ||= Sdr::Repository.status(druid: cocina_object.externalIdentifier)
      return cocina_object if status.open?

      raise Error, 'Object cannot be opened' unless status.openable?

      open_cocina_object = Dor::Services::Client.object(cocina_object.externalIdentifier)
                                                .version.open(description: version_description,
                                                              opening_user_name: user_name)
      Cocina::VersionAndLockUpdater.call(cocina_object:, version: open_cocina_object.version,
                                         lock: open_cocina_object.lock)
    rescue Dor::Services::Client::Error => e
      raise Error, "Opening failed: #{e.message}"
    end

    # @param [Cocina::Models::DRO] cocina_object
    # @param [String] description the description of the update for DSA Event
    # @param [String] user_name the sunetid of the user performing the action
    # @raise [Error] if there is an error updating the object
    # @return [Cocina::Models::DRO] the updated cocina object
    def self.update(cocina_object:, user_name:, description: nil)
      Dor::Services::Client.object(cocina_object.externalIdentifier).update(params: cocina_object,
                                                                            description:,
                                                                            user_name:)
    rescue Dor::Services::Client::Error => e
      raise Error, "Updating failed: #{e.message}"
    end

    # @param [String] druid
    # @raise [Error] if there is an error discarding the draft
    def self.discard_draft(druid:)
      status = Sdr::Repository.status(druid:)
      raise Error, 'Draft cannot be discarded' unless status.discardable?

      if status.version == 1
        Dor::Services::Client.object(druid).destroy
      else
        Dor::Services::Client.object(druid).version.discard
      end
    rescue Dor::Services::Client::Error => e
      raise Error, "Updating failed: #{e.message}"
    end

    # @param [String] druid
    # @return [Cocina::Models::DRO] the latest user version of the object, or nil if not found
    def self.find_latest_user_version(druid:)
      version_client = Dor::Services::Client.object(druid).user_version
      head_user_version = version_client.inventory.find(&:head?)
      return unless head_user_version

      version_client.find(head_user_version.userVersion)
    end
  end
end
