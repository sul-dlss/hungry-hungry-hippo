# frozen_string_literal: true

module Elements
  # A single link in the header nav, bootstrap-style
  class NavLinkComponent < ViewComponent::Base
    def initialize(title:, path:)
      @title = title
      @path = path
      super
    end

    attr_reader :title, :path
  end
end
