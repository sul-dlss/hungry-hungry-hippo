# frozen_string_literal: true

module Show
  # Component for rendering a show page header.
  class HeaderComponent < ApplicationComponent
    def initialize(title:, status_message:, edit_path:, destroy_path:, editable: false, discardable: false) # rubocop:disable Metrics/ParameterLists
      @title = title
      @status_message = status_message
      @edit_path = edit_path
      @editable = editable
      @destroy_path = destroy_path
      @discardable = discardable
      super()
    end

    attr_reader :title, :status_message, :edit_path, :destroy_path

    def discardable?
      @discardable
    end

    def editable?
      @editable
    end
  end
end
