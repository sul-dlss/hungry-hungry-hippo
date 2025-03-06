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
        link_to(work.title, work_or_wait_path(work), data: { turbo_frame: '_top' }),
        link_to(work.collection.title, collection_or_wait_path(work.collection), data: { turbo_frame: '_top' }),
        @status_map[work.id].status_message,
        work.bare_druid,
        work.object_updated_at ? I18n.l(work.object_updated_at, format: '%b %d, %Y') : nil
      ]
    end
  end
end
