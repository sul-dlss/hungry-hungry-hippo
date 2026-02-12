# frozen_string_literal: true

module Works
  # Component for rendering the work edit form and its associated tabs and panes.
  class FormComponent < ApplicationComponent
    def initialize(work_form:, work_presenter:, collection:, work_content:, default_tab: :files)
      @work_form = work_form
      @work_presenter = work_presenter
      @collection = collection
      @work_content = work_content
      @default_tab = default_tab
      super()
    end

    attr_reader :work_form, :work_presenter, :collection, :work_content, :default_tab

    def work
      return unless work_presenter

      work_presenter.work
    end

    def tabs_component(component:, active_tab_name:)
      return Works::Form::GithubRepositoryWorkTabsComponent.new(component:, active_tab_name:) if work.is_a?(GithubRepository)

      Works::Form::DefaultTabsComponent.new(component:, active_tab_name:)
    end

    def panes_component(component:, form:, form_id:, discard_draft_form_id:, work_presenter: @work_presenter, active_tab_name:)
      return Works::Form::GithubRepositoryWorkPanesComponent.new(component:, form:, form_id:, discard_draft_form_id:, work_presenter: @work_presenter, active_tab_name:, work_form:, work_content:, collection:) if work.is_a?(GithubRepository)

      Works::Form::DefaultPanesComponent.new(component:, form:, form_id:, discard_draft_form_id:, work_presenter: @work_presenter, active_tab_name:, work_form:, work_content:, collection:)
    end
  end
end
