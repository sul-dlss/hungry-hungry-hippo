# frozen_string_literal: true

module Elements
  # A single link in the header nav, bootstrap-style
  class NavLinkComponent < ViewComponent::Base
    def initialize(nav_link:)
      super
      @title = nav_link[:title]
      @path = nav_link[:path]
    end
  end
end
