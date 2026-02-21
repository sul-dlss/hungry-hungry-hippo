# frozen_string_literal: true

module Collections
  module Edit
    # Component for rendering a tab pane for a collection edit form.
    class PaneComponent < ApplicationComponent
      renders_one :deposit_button # only renders if provided
      renders_one :help

      def initialize(collection_presenter:, label:, previous_tab_btn: true, next_tab_btn: true, mark_required: false, # rubocop:disable Metrics/ParameterLists
                     **pane_args)
        @collection_presenter = collection_presenter
        @previous_tab_btn = previous_tab_btn
        @next_tab_btn = next_tab_btn
        @label = label
        @mark_required = mark_required
        @pane_args = pane_args
        super()
      end

      attr_reader :pane_args, :mark_required

      def previous_tab_btn?
        @previous_tab_btn
      end

      def next_tab_btn?
        @next_tab_btn
      end

      def cancel_path
        @collection_presenter.nil? ? dashboard_path : collection_path(@collection_presenter)
      end

      def label
        mark_label_required(label: @label, mark_required:)
      end
    end
  end
end
