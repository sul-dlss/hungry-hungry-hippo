# frozen_string_literal: true

module Elements
  module Tables
    # Component for rendering a treegrid table (e.g., file hierarchy).
    class TreegridTableComponent < BaseTableComponent
      renders_many :rows, types: {
        branch: Elements::Tables::TreegridBranchRowComponent,
        leaf: Elements::Tables::TreegridLeafRowComponent
      }

      def initialize(**args)
        args[:classes] = merge_classes(%w[table-treegrid table-sm mb-5], args[:classes])
        args[:role] = 'treegrid'
        args[:data] = { controller: 'treegrid', action: 'keydown->treegrid#navigate', treegrid_target: 'table' }
        super
      end
    end
  end
end
