# frozen_string_literal: true

module Elements
  # Displays the top bread crumb navigation
  class BreadcrumbNavComponent < ApplicationComponent
    renders_many :breadcrumbs, types: {
      breadcrump: { renders: BreadcrumbComponent, as: :breadcrumb },
      title_breadcrumb: { renders: ->(**args) { BreadcrumbComponent.new(truncate_length: 75, **args) },
                          as: :title_breadcrumb },
      collection_breadcrumb: { renders: lambda { |**args|
        BreadcrumbComponent.new(truncate_length: 50, **args)
      },
                               as: :collection_breadcrumb }

    }
  end
end
