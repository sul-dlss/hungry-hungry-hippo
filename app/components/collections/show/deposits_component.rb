# frozen_string_literal: true

module Collections
  module Show
    # Component for rendering a list of deposits for the collection show page.
    class DepositsComponent < ApplicationComponent
      def initialize(work_statuses:, works:)
        @work_statuses = work_statuses
        @works = works
        super()
      end

      attr_reader :work_statuses, :works

      def collection_deposits
        @collection_deposits ||= works.map do |work|
          {
            id: dom_id(work),
            values: values_for(work)
          }
        end
      end

      def values_for(work)
        presenter = work_presenter_for(work)
        [
          helpers.link_to(work.title, work_or_wait_path(work), data: { turbo_frame: '_top' }),
          work.user.name,
          presenter.status_message,
          work.object_updated_at ? helpers.l(work.object_updated_at, format: '%b %d, %Y') : nil,
          presenter.sharing_link
        ]
      end

      def work_presenter_for(work)
        WorkPresenter.new(work:,
                          version_status: work_statuses.fetch(
                            work.druid, VersionStatus::NilStatus.new
                          ),
                          work_form: WorkForm.new(druid: work.druid))
      end
    end
  end
end
