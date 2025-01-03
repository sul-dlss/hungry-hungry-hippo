# frozen_string_literal: true

module Dashboard
  module Show
    # Component for rendering a table on the work show page.
    class WorksListComponent < ApplicationComponent
      def initialize(collection:, status_map:)
        @collection = collection
        @status_map = status_map
        super()
      end

      attr_reader :collection

      delegate :works, to: :collection

      def id
        @id ||= dom_id(collection, 'table')
      end

      def id_for(work)
        dom_id(work, id)
      end

      def label
        "Works in #{collection.title}"
      end

      def values_for(work)
        [
          link_to(work.title, link_for(work)),
          @status_map[work.id].status_message,
          work.user.name,
          work.object_updated_at ? I18n.l(work.object_updated_at, format: '%b %d, %Y') : nil,
          work.druid ? link_to(nil, Sdr::Purl.from_druid(druid: work.druid)) : nil
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
