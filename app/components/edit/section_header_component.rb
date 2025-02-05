# frozen_string_literal: true

module Edit
  # Component for rendering a section header.
  class SectionHeaderComponent < ApplicationComponent
    def initialize(title:)
      @title = title
      super
    end

    def call
      tag.h2(@title, class: 'h5 my-3')
    end
  end
end
