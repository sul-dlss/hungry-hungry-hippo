# frozen_string_literal: true

module Elements
  # Displays the top breadcrumb navigation
  class BreadcrumbNavComponent < ApplicationComponent
    renders_many :breadcrumbs, types: {
      default: {
        renders: BreadcrumbComponent, as: :breadcrumb
      },
      title: {
        renders: ->(**args) { BreadcrumbComponent.new(truncate_length: 75, **args) }, as: :title_breadcrumb
      },
      collection: {
        renders: ->(**args) { BreadcrumbComponent.new(truncate_length: 50, **args) }, as: :collection_breadcrumb
      }
    }

    def page_title_from_breadcrumbs
      breadcrumbs.filter_map(&:truncated_text).unshift('SDR').join(' | ')
    end
  end
end
