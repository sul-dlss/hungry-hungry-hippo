# frozen_string_literal: true

module Works
  module Edit
    # Component for rendering a tab pane for a work edit form.
    class PaneComponent < ApplicationComponent
      renders_one :deposit_button # If not provided will render Next button
      renders_one :help

      def initialize(form_id:, work_presenter:, discard_draft_form_id: nil, # rubocop:disable Metrics/ParameterLists
                     previous_tab_btn: true, next_tab_btn: true, **pane_args)
        @pane_args = pane_args
        @form_id = form_id
        @work_presenter = work_presenter
        @discard_draft_form_id = discard_draft_form_id
        @previous_tab_btn = previous_tab_btn
        @next_tab_btn = next_tab_btn
        super()
      end

      attr_reader :pane_args, :form_id, :work_presenter, :discard_draft_form_id

      def tab_id
        "#{pane_args[:tab_name]}-tab"
      end

      def previous_tab_btn?
        @previous_tab_btn
      end

      def next_tab_btn?
        @next_tab_btn
      end

      def cancel_path
        @work_presenter.nil? ? dashboard_path : work_path(@work_presenter)
      end

      def draft_btns?
        discard_draft_form_id.present?
      end
    end
  end
end
