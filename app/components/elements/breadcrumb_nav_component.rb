# frozen_string_literal: true

module Elements
  # Displays the top bread crumb navigation
  class BreadcrumbNavComponent < ApplicationComponent
    renders_many :breadcrumbs, BreadcrumbComponent

    def initialize(dashboard: true, admin: false)
      @dashboard = dashboard
      @admin = admin
      super()
    end

    def dashboard?
      @dashboard
    end

    def admin?
      @admin
    end
  end
end
