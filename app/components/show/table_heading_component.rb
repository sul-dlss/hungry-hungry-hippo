# frozen_string_literal: true

module Show
  # Component for rendering a table heading.
  class TableHeadingComponent < ApplicationComponent
    def initialize(text:, classes: [], presenter: nil, tab: nil)
      @text = text
      @classes = classes
      # @presenter is used to render an optional edit button
      @presenter = presenter
      # Specify a tab to include in edit link (e.g., ?tab=contributors)
      @tab = tab
      super
    end

    def classes
      merge_classes('h3', @classes)
    end

    attr_reader :text, :presenter, :tab
  end
end
