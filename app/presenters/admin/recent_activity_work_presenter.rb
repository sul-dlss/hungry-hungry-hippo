# frozen_string_literal: true

module Admin
  # Presenter for recent activity work items
  class RecentActivityWorkPresenter
    include ActionView::Helpers::UrlHelper
    include LinkHelper

    def self.values_for(work:)
      new(work:).values_for
    end

    # Initializes the presenter with a work object.
    #
    # @param work [Work] the work object to present
    def initialize(work:)
      @work = work
    end

    attr_reader :work

    def values_for
      [
        work_link,
        collection_link
      ]
    end

    private

    def work_link
      return work.title unless work.druid

      link_to(work.title, Rails.application.routes.url_helpers.work_path(work))
    end

    def collection_link
      link_to(work.collection.title, Rails.application.routes.url_helpers.collection_path(work.collection))
    end
  end
end
