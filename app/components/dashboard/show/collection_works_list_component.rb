# frozen_string_literal: true

module Dashboard
  module Show
    # Component for rendering a table on the work show page for a collection's works.
    class CollectionWorksListComponent < ApplicationComponent
      WORK_LIMIT = 4

      def initialize(collection:, status_map:)
        @collection = collection
        @status_map = status_map
        super()
      end

      attr_reader :collection

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
        presenter = WorkPresenter.new(work:, version_status: @status_map.fetch(work.id, VersionStatus::NilStatus.new),
                                      work_form: WorkForm.new(druid: work.druid))
        [
          link_to(work.title, work_or_wait_path(work)),
          presenter.status_message,
          work.user.name,
          work.object_updated_at ? I18n.l(work.object_updated_at, format: '%b %d, %Y') : nil,
          presenter.sharing_link
        ]
      end

      def works
        @works ||= helpers.authorized_scope(collection.works, as: :collection, scope_options: { collection: })
                          .order(object_updated_at: :desc)
      end

      def see_all?
        works.length > WORK_LIMIT
      end
    end
  end
end
