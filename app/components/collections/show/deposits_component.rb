# frozen_string_literal: true

module Collections
  module Show
    # Component for rendering a list of deposits for the collection show page.
    class DepositsComponent < ApplicationComponent
      def initialize(presenters:, search_term: nil)
        @presenters = presenters
        @search_term = search_term
        super()
      end

      attr_reader :presenters, :search_term

      def empty_message
        return 'No deposits to this collection.' if search_term.blank?

        "No deposits to this collection match the search: '#{search_term}'."
      end

      def collection_deposits
        @collection_deposits ||= presenters.map do |presenter|
          {
            id: dom_id(presenter),
            values: values_for(presenter)
          }
        end
      end

      def values_for(presenter)
        work = presenter.work
        [
          helpers.link_to(work.title, work_or_wait_path(work), data: { turbo_frame: '_top' }),
          work.user.name,
          presenter.status_message,
          work.object_updated_at ? helpers.l(work.object_updated_at, format: '%b %d, %Y') : nil,
          presenter.sharing_link
        ]
      end
    end
  end
end
