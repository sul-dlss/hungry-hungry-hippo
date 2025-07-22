# frozen_string_literal: true

module Collections
  module Edit
    # Component for rendering a tab pane for a collection edit form.
    class PaneComponent < ::Edit::TabForm::PaneComponent
      renders_one :deposit_button # only renders if provided

      def initialize(collection_presenter:, previous_tab_btn: true, next_tab_btn: true, **pane_args)
        @collection_presenter = collection_presenter
        @previous_tab_btn = previous_tab_btn
        @next_tab_btn = next_tab_btn
        super(**pane_args)
      end

      # Preset footer slot consisting of cancel button, previous, next and deposit button as needed
      # rubocop:disable Metrics/AbcSize
      def footer
        tag.div(class: 'd-flex') do
          concat render Elements::CancelButtonComponent.new(link: cancel_path, classes: 'me-2')
          concat render ::Edit::TabForm::PreviousButtonComponent.new(tab_id:, classes: 'me-2') if previous_tab_btn?
          concat deposit_button if deposit_button?
          concat render ::Edit::TabForm::NextButtonComponent.new(tab_id:) if next_tab_btn?
        end
      end
      # rubocop:enable Metrics/AbcSize

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
