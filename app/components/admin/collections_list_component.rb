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
        link_to(collection.title, collection_or_wait_path(collection), data: { turbo_frame: '_top' }),
        collection.bare_druid,
        roles_for(collection)
      ]
    end

    private

    def roles_for(collection)
      user.roles_for(collection:).map(&:titleize).join(', ')
    end
  end
end
