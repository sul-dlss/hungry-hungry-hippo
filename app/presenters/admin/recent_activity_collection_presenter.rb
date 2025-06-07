# frozen_string_literal: true

module Admin
  # Presenter for recent activity collection items.
  class RecentActivityCollectionPresenter
    include ActionView::Helpers::UrlHelper
    include LinkHelper

    def initialize(collection)
      @collection = collection
    end

    attr_reader :collection

    def values_for
      return [collection.title] unless collection.druid

      [
        link_to(collection.title, Rails.application.routes.url_helpers.collection_path(collection))
      ]
    end
  end
end
