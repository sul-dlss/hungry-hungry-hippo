# frozen_string_literal: true

module Collections
  module Edit
    # Component for rendering a tab pane for a collection edit form.
    class PaneComponent < ::Edit::TabForm::PaneComponent
      renders_one :deposit_button # If not provided will render Next button

      def initialize(collection_presenter:, **pane_args)
        @collection_presenter = collection_presenter
        super(**pane_args)
      end

      # Preset footer slot consisting of cancel button plus next or deposit button.
      def footer
        tag.div(class: 'd-flex') do
          concat render Elements::CancelButtonComponent.new(link: cancel_path, classes: 'me-2')
          if deposit_button?
            concat deposit_button
          else
            concat render ::Edit::TabForm::NextButtonComponent.new(tab_id:)
          end
        end
      end

      def cancel_path
        @collection_presenter.nil? ? dashboard_path : collection_path(@collection_presenter)
      end
    end
  end
end
