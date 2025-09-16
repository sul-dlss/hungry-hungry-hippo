# frozen_string_literal: true

module Elements
  # A single link in the header nav, bootstrap-style
  class NavLinkComponent < ViewComponent::Base
    def initialize(title:, path:, data: {})
      @title = title
      @path = path
      @data = data
      super()
    end

    attr_reader :title, :path, :data
  end
end
