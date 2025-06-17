# frozen_string_literal: true

module Dashboard
  module Show
    # Component for rendering a table on the work show page with works.
    class WorksListComponent < ApplicationComponent
      def initialize(works:, id:)
        @works = works
        @id = id
        super()
      end

      attr_reader :works, :id

      def id_for(work)
        dom_id(work, id)
      end

      def values_for(work)
        [
          link_to(work.title, work_or_wait_path(work)),
          link_to(work.collection.title, collection_path(work.collection.druid)),
          work.user.name,
          I18n.l(work.updated_at, format: '%b %d, %Y')
        ]
      end
    end
  end
end
