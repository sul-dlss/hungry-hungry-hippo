# frozen_string_literal: true

module ModelSync
  # Updates a Work model object based on a DRO
  class Work
    def self.call(...)
      new(...).call
    end

    # @param [Work] work
    # @param [Cocina::Models::DRO,Cocina::Models::RequestDRO] cocina_object
    def initialize(work:, cocina_object:)
      @work = work
      @cocina_object = cocina_object
    end

    def call
      # Need collections in cocina for update.
      # TODO: Test when showing a work and there is not a Collection AR for the collection in the cocina does not exist.
      # work.update!(title:, collection:)
      work.update!(title:)
    end

    private

    attr_reader :work, :cocina_object

    def title
      CocinaSupport.title_for(cocina_object:)
    end

    def collection_druid
      @collection_druid ||= CocinaSupport.collection_druid_for(cocina_object:)
    end

    def collection
      Collection.find_by!(druid: collection_druid)
    end
  end
end
