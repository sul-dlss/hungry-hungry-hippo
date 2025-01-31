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
    # @return [Cocina::Models::DRO] the registered cocina object
    # @raise [Error] if there is an error depositing the work
    def self.register(cocina_object:, assign_doi: false)
      response_cocina_object = Dor::Services::Client.objects.register(params: cocina_object, assign_doi:)

      # Create workflow destroys existing steps if called again, so need to check if already created.
      Sdr::Workflow.create_unless_exists(response_cocina_object.externalIdentifier, 'registrationWF', version: 1)
      response_cocina_object
    rescue Dor::Services::Client::Error, Sdr::Workflow::Error => e
      raise Error, "Registration failed: #{e.message}"
    end

    # @param [String] druid the druid of the object
    # @raise [Error] if there is an error initiating accession
    def self.accession(druid:)
      # Close the version, which will also start accessioning
      # user_versions = mode for handling user versioning.
      # Setting to none (do nothing with user versioning) for now.
      Dor::Services::Client.object(druid).version.close(user_versions: 'none')
    rescue Dor::Services::Client::Error => e
      raise Error, "Initiating accession failed: #{e.message}"
    end

    # @param [Cocina::Models::DRO] cocina_object
    # @param [String] version_description the description of the version
    # @raise [Error] if there is an error opening the object
    # @return [Cocina::Models::DRO] the updated cocina object
    def self.open_if_needed(cocina_object:, version_description: 'Update')
      status = Sdr::Repository.status(druid: cocina_object.externalIdentifier)
      return cocina_object if status.open?

      raise Error, 'Object cannot be opened' unless status.openable?

      open_cocina_object = Dor::Services::Client.object(cocina_object.externalIdentifier)
                                                .version.open(description: version_description)
      Cocina::VersionAndLockUpdater.call(cocina_object:, version: open_cocina_object.version,
                                         lock: open_cocina_object.lock)
    rescue Dor::Services::Client::Error => e
      raise Error, "Opening failed: #{e.message}"
    end

    # @param [Cocina::Models::DRO] cocina_object
    # @raise [Error] if there is an error updating the object
    # @return [Cocina::Models::DRO] the updated cocina object
    def self.update(cocina_object:)
      Dor::Services::Client.object(cocina_object.externalIdentifier).update(params: cocina_object)
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
  end
end
