# frozen_string_literal: true

module Works
  module Form
    # Component for rendering the default set of tabs and panes for a work form.
    class DefaultPanesComponent < ApplicationComponent
      def initialize(component:, form:, form_id:, discard_draft_form_id:, work_presenter:, active_tab_name:, work_form:, work_content:, collection:)
        @component = component
        @form = form
        @form_id = form_id
        @discard_draft_form_id = discard_draft_form_id
        @work_presenter = work_presenter
        @active_tab_name = active_tab_name
        @work_form = work_form
        @work_content = work_content
        @collection = collection
        super()
      end

      attr_reader :component, :form, :form_id, :discard_draft_form_id, :work_presenter, :active_tab_name, :work_form, :work_content, :collection

      def license_presenter
        @license_presenter ||= LicensePresenter.new(work_form:, collection:)
      end
    end
  end
end
