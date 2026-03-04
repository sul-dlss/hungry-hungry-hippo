# frozen_string_literal: true

module Edit
  # Component for rendering a section header.
  class SectionHeaderComponent < ApplicationComponent
    def initialize(title:)
      @title = title
      super()
    end

    def call
      tag.h3(@title, class: 'mb-3 mt-0')
    end
  end
end
