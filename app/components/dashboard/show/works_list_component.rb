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
        presenter = WorkPresenter.new(work:, version_status: @status_map[work.id], work_form: WorkForm.new)
        [
          link_to(work.title, work_or_wait_path(work)),
          presenter.status_message,
          work.user.name,
          work.object_updated_at ? I18n.l(work.object_updated_at, format: '%b %d, %Y') : nil,
          persistent_link_for(work)
        ]
      end

      def works
        collection.works.filter { |work| helpers.allowed_to?(:show, work) }
      end

      private

      def persistent_link_for(work)
        if work.druid.nil?
          nil
        elsif work.doi_assigned?
          link_to(nil, Doi.url(druid: work.druid))
        else
          link_to(nil, Sdr::Purl.from_druid(druid: work.druid))
        end
      end
    end
  end
end
