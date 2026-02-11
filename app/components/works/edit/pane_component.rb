# frozen_string_literal: true

module Works
  module Edit
    # Component for rendering a tab pane for a work edit form.
    class PaneComponent < ApplicationComponent
      renders_one :deposit_button # If not provided will render Next button
      renders_one :help

      def initialize(form_id:, work_presenter:, discard_draft_form_id:, # rubocop:disable Metrics/ParameterLists
                     previous_tab_btn: true, next_tab_btn: true, render: false, **pane_args)
        @pane_args = pane_args
        @form_id = form_id
        @work_presenter = work_presenter
        @discard_draft_form_id = discard_draft_form_id
        @previous_tab_btn = previous_tab_btn
        @next_tab_btn = next_tab_btn
        @render = render
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

      # Only render the pane if the form indicates that the tab should be rendered or
      # if explicitly set to render (i.e. deposit tab). This allows for tabs to be
      # conditionally rendered based on the state of the form.
      # @work_presenter may be nil when rendering a new work form,
      # so in that case we rely solely on the explicit render argument.
      def render?
        return true unless @work_presenter

        @work_presenter.render_tabs.include?(pane_args[:tab_name]) || @render
      end
    end
  end
end
