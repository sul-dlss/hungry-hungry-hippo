# frozen_string_literal: true

module Dashboard
  module Show
    # Component for rendering a table on the work show page with works pending review.
    class PendingReviewListComponent < ApplicationComponent
      def initialize(works:)
        @works = works
        super()
      end

      attr_reader :works

      def id
        'pending-review-table'
      end

      def id_for(work)
        dom_id(work, id)
      end

      def values_for(work)
        [
          link_to(work.title, link_for(work)),
          link_to(work.collection.title, collection_path(druid: work.collection.druid)),
          work.user.name,
          I18n.l(work.updated_at, format: '%b %d, %Y')
        ]
      end

      private

      def link_for(work)
        return wait_works_path(work) unless work.druid

        work_path(druid: work.druid)
      end
    end
  end
end
