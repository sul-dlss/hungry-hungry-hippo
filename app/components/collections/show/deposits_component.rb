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
        @collection_deposits ||= collection.works.map do |work|
          {
            id: work.druid || work.id,
            values: values_for(work)
          }
        end
      end

      def values_for(work)
        [
          helpers.link_to(work.title, link_for(work)),
          work.user.name,
          status_for(work),
          work.object_updated_at ? helpers.l(work.object_updated_at, format: '%b %d, %Y') : nil,
          persistent_link_for(work)
        ]
      end

      def link_for(work)
        return helpers.work_path(druid: work.druid) if work.druid

        helpers.wait_works_path(work)
      end

      def status_for(work)
        work_statuses.fetch(work.druid, VersionStatus::NilStatus.new).status_message
      end

      def persistent_link_for(work)
        if work.druid.nil?
          'N/A (still depositing)'
        elsif work.doi_assigned?
          helpers.link_to(nil, Doi.url(druid: work.druid))
        else
          helpers.link_to(nil, Sdr::Purl.from_druid(druid: work.druid))
        end
      end
    end
  end
end
