# frozen_string_literal: true

module Show
  # Component for rendering a show page header.
  class HeaderComponent < ApplicationComponent
    def initialize(presenter:)
      @presenter = presenter
      super()
    end
    # def initialize(title:, status_message:, edit_path:, destroy_path:, editable: false, discardable: false)
    #   @title = title
    #   @status_message = status_message
    #   @edit_path = edit_path
    #   @editable = editable
    #   @destroy_path = destroy_path
    #   @discardable = discardable
    #   super()
    # end

    # attr_reader :title, :status_message, :edit_path, :destroy_path
    attr_reader :presenter

    delegate :title, :status_message, to: :presenter

    # def discardable?
    #   @discardable
    # end

    # def editable?
    #   @editable
    # end
  end
end
