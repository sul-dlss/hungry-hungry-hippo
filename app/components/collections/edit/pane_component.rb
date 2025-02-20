# frozen_string_literal: true

module Collections
  module Edit
    # Component for rendering a tab pane for a collection edit form.
    class PaneComponent < ::Edit::TabForm::PaneComponent
      renders_one :deposit_button # If not provided will render Next button

      # Preset footer slot consisting of cancel button plus next or deposit button.
      def footer
        tag.div(class: 'd-flex') do
          concat render Elements::CancelButtonComponent.new(link: dashboard_path, classes: 'me-2')
          if deposit_button?
            concat deposit_button
          else
            concat render ::Edit::TabForm::NextButtonComponent.new(tab_id:)
          end
        end
      end
    end
  end
end
