# frozen_string_literal: true

module Collections
  module Show
    # Component for rendering a list of deposits for the collection show page.
    class DepositsComponent < ApplicationComponent
      def initialize(presenter:)
        @presenter = presenter
        super()
      end
      attr_reader :presenter

      delegate :collection, :work_statuses, to: :presenter

      def collection_deposits
        @collection_deposits ||= collection.works.order(:title).map do |work|
          {
            id: dom_id(work),
            values: values_for(work)
          }
        end
      end

      def headers
        [
          TableHeader.new(label: 'Deposit'),
          TableHeader.new(label: 'Owner'),
          TableHeader.new(label: 'Status'),
          TableHeader.new(label: 'Modified'),
          TableHeader.new(label: t('sharing_link.label'), tooltip: t('sharing_link.tooltip_html'))
        ]
      end

      def values_for(work)
        presenter = work_presenter_for(work)
        [
          helpers.link_to(work.title, work_or_wait_path(work)),
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
