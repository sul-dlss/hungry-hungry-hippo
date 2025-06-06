# frozen_string_literal: true

# Updates a Collection model object based on a Cocina Collection
#
# Syncing should be performed whenever the Collection is retrieved (since it may have been updated externally from H3)
# and whenever the work is updated by the user.
class CollectionModelSynchronizer
  def self.call(...)
    new(...).call
  end

  # @param [Collection] collection
  # @param [Cocina::Models::CollectionWithMetadata,Cocina::Models::RequestCollection] cocina_object
  def initialize(collection:, cocina_object:, raise: true)
    @collection = collection
    @cocina_object = cocina_object
    @raise = raise
  end

  def call
    collection.update!(**update_params)
  end

  private

  attr_reader :collection, :cocina_object

  def update_params
    {
      title:,
      version:
    }.tap do |params|
      params[:object_updated_at] = cocina_object.try(:modified)
    end.compact
  end

  def title
    Cocina::Parser.title_for(cocina_object:)
  end

  def version
    Cocina::Parser.version_for(cocina_object:)
  end
end
