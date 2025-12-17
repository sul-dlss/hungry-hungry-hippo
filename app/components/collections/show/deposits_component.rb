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
        presenters.map do |presenter|
          {
            id: dom_id(presenter),
            values: values_for(presenter)
          }
        end
      end

      def values_for(presenter)
        work = presenter.work
        title_with_icon = work.github_repo.present? ? "#{work.title} #{github_icon}" : work.title
        [
          helpers.link_to(title_with_icon.html_safe, work_or_wait_path(work), data: { turbo_frame: '_top' }),
          work.user.name,
          presenter.status_message,
          work.object_updated_at ? helpers.l(work.object_updated_at, format: '%b %d, %Y') : nil,
          presenter.sharing_link
        ]
      end

      private

      def github_icon
        '<i class="bi bi-github" title="Linked to GitHub"></i>'
      end
    end
  end
end
