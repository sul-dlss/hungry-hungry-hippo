# frozen_string_literal: true

module Works
  module Edit
    # Component for rendering a tab pane for a work edit form.
    class PaneComponent < ApplicationComponent
      renders_one :deposit_button # If not provided will render Next button
      renders_one :help

      attr_accessor :active_tab_name

      def initialize(form:, work_presenter:, label:, discard_draft_form_id: nil, previous_tab_btn: true, # rubocop:disable Metrics/ParameterLists
                     next_tab_btn: true, **pane_args)
        @pane_args = pane_args
        @form = form
        @work_presenter = work_presenter
        @discard_draft_form_id = discard_draft_form_id
        @previous_tab_btn = previous_tab_btn
        @next_tab_btn = next_tab_btn
        @label = label
        super()
      end

      attr_reader :pane_args, :form, :work_presenter, :discard_draft_form_id, :label

      def pane_component
        SdrViewComponents::TabForm::PaneComponent.new(label:, **pane_args).tap do |component|
          # PaneComponent only accepts active_tab_name via attr_accessor, not as a constructor keyword, so it
          # has to be built first and assigned afterward.
          component.active_tab_name = active_tab_name
        end
      end

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
