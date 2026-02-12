# frozen_string_literal: true

module Works
  # Component for rendering the work edit form and its associated tabs and panes.
  class FormComponent < ApplicationComponent
    def initialize(work_form:, work_presenter:, collection:, work_content:, license_presenter:, work:)
      @work_form = work_form
      @work_presenter = work_presenter
      @collection = collection
      @work_content = work_content
      @license_presenter = license_presenter
      @work = work
      super()
    end

    attr_reader :work_form, :work_presenter, :collection, :work_content, :license_presenter, :work
  end
end
