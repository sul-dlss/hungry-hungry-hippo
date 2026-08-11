# frozen_string_literal: true

module Collections
  module Edit
    # Component for rendering a tab pane for a collection edit form.
    class PaneComponent < ApplicationComponent
      renders_one :deposit_button # only renders if provided
      renders_one :help

      attr_accessor :active_tab_name

      def initialize(collection_presenter:, label:, previous_tab_btn: true, next_tab_btn: true, **pane_args)
        @collection_presenter = collection_presenter
        @previous_tab_btn = previous_tab_btn
        @next_tab_btn = next_tab_btn
        @label = label
        @pane_args = pane_args
        super()
      end

      attr_reader :pane_args, :label

      def pane_component
        SdrViewComponents::TabForm::PaneComponent.new(label:, **pane_args).tap do |component|
          # PaneComponent only accepts active_tab_name via attr_accessor, not as a constructor keyword, so it
          # has to be built first and assigned afterward.
          component.active_tab_name = active_tab_name
        end
      end

      def previous_tab_btn?
        @previous_tab_btn
      end

      def next_tab_btn?
        @next_tab_btn
      end

      def cancel_path
        @collection_presenter.nil? ? dashboard_path : collection_path(@collection_presenter)
      end
    end
  end
end
