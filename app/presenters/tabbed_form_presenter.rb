# frozen_string_literal: true

# Presents the DOM ids and initially-active tab shared by TabListComponent-based edit forms.
class TabbedFormPresenter
  include ActionView::RecordIdentifier

  def initialize(model:, default_tab_name:, active_tab_name: nil, discard_draft_form_id: nil)
    @model = model
    @default_tab_name = default_tab_name
    @requested_active_tab_name = active_tab_name
    @discard_draft_form_id = discard_draft_form_id
  end

  attr_reader :model, :discard_draft_form_id

  def form_id
    @form_id ||= dom_id(model, 'tabbed_form')
  end

  def active_tab_name
    @requested_active_tab_name || @default_tab_name
  end
end
