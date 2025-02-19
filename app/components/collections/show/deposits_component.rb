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

      def values_for(work)
        [
          helpers.link_to(work.title, work_or_wait_path(work)),
          work.user.name,
          status_for(work),
          work.object_updated_at ? helpers.l(work.object_updated_at, format: '%b %d, %Y') : nil,
          persistent_link_for(work)
        ]
      end

      def status_for(work)
        presenter = WorkPresenter.new(work:,
                                      version_status: work_statuses.fetch(work.druid, VersionStatus::NilStatus.new),
                                      work_form: WorkForm.new)

        presenter.status_message
      end

      def persistent_link_for(work)
        if work.druid.nil?
          ''
        elsif work.doi_assigned?
          helpers.link_to(nil, Doi.url(druid: work.druid))
        else
          helpers.link_to(nil, Sdr::Purl.from_druid(druid: work.druid))
        end
      end
    end
  end
end
