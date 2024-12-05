# frozen_string_literal: true

module ModelSync
  # Updates a Work model object based on a DRO
  #
  # Syncing should be performed whenever the DRO is retrieved (since it may have been updated externally from H3)
  # and whenever the work is updated by the user.
  class Work
    class Error < StandardError; end

    def self.call(...)
      new(...).call
    end

    # @param [Work] work
    # @param [Cocina::Models::DROWithMetadata,Cocina::Models::RequestDRO] cocina_object
    # @param [Boolean] raise whether to raise an error if the collection is not found
    # @raise [Error] if the collection is not found
    def initialize(work:, cocina_object:, raise: true)
      @work = work
      @cocina_object = cocina_object
      @raise = raise
    end

    def call
      work.update!(**update_params)
    end

    private

    attr_reader :work, :cocina_object

    def update_params
      {
        title: title,
        collection: collection
      }.tap do |params|
        params[:object_updated_at] = cocina_object.try(:modified)
      end.compact
    end

    def title
      CocinaSupport.title_for(cocina_object:)
    end

    def collection_druid
      @collection_druid ||= CocinaSupport.collection_druid_for(cocina_object:)
    end

    def collection
      Collection.find_by!(druid: collection_druid)
    rescue ActiveRecord::RecordNotFound
      raise Error, "Collection not found: #{collection_druid}" if @raise

      work.collection
    end
  end
end
