# frozen_string_literal: true

module Admin
  # Component for rendering a table of collections on the admin user page.
  class CollectionsListComponent < ApplicationComponent
    def initialize(collections:, user:, id:, label:, empty_message: 'No collections.')
      @collections = collections
      @user = user
      @id = id
      @label = label
      @empty_message = empty_message
      super()
    end

    attr_reader :collections, :id, :label, :empty_message, :user

    def id_for(collection)
      dom_id(collection, id)
    end

    def values_for(collection)
      [
        link_to(collection.title, link_for(collection)),
        collection.druid,
        roles_for(collection)
      ]
    end

    private

    def link_for(collection)
      return wait_collections_path(collection) unless collection.druid

      collection_path(druid: collection.druid)
    end

    def roles_for(collection)
      user.roles_for(collection:).map(&:titleize).join(', ')
    end
  end
end
