# frozen_string_literal: true

module Dashboard
  module Show
    # Component for rendering a table on the work show page with work drafts.
    class DraftsListComponent < ApplicationComponent
      def initialize(works:)
        @works = works
        super()
      end

      attr_reader :works

      def id
        'drafts-table'
      end

      def id_for(work)
        dom_id(work, id)
      end

      def values_for(work)
        [
          link_to(work.title, work_or_wait_path(work)),
          link_to(work.collection.title, collection_path(work.collection.druid)),
          I18n.l(work.updated_at, format: '%b %d, %Y')
        ]
      end
    end
  end
end
