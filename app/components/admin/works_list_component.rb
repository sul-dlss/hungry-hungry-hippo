# frozen_string_literal: true

module Admin
  # Component for rendering a table of works on the admin user page.
  class WorksListComponent < ApplicationComponent
    def initialize(works:, id:, label:, status_map:, empty_message: 'No works.')
      @works = works
      @id = id
      @label = label
      @empty_message = empty_message
      @status_map = status_map
      super()
    end

    attr_reader :works, :id, :label, :empty_message

    def id_for(work)
      dom_id(work, id)
    end

    def values_for(work)
      [
        link_to(work.title, work_link(work)),
        link_to(work.collection.title, collection_link(work.collection)),
        @status_map[work.id].status_message,
        work.druid,
        I18n.l(work.object_updated_at, format: '%b %d, %Y')
      ]
    end

    private

    def work_link(work)
      return wait_works_path(work) unless work.druid

      work_path(druid: work.druid)
    end

    def collection_link(collection)
      return wait_collections_path(collection) unless collection.druid

      collection_path(druid: collection.druid)
    end
  end
end
