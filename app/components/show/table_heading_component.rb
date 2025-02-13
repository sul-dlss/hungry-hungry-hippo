# frozen_string_literal: true

module Show
  # Component for rendering a table heading.
  class TableHeadingComponent < Elements::HeadingComponent
    def initialize(**args)
      args[:level] = :h2
      args[:classes] = merge_classes('h3', args[:classes])
      super
    end
  end
end
