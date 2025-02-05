# frozen_string_literal: true

module Elements
  # Displays the top bread crumb navigation
  class BreadcrumbNavComponent < ApplicationComponent
    renders_many :breadcrumbs, BreadcrumbComponent
  end
end
