# frozen_string_literal: true

module Collections
  module Edit
    # Component for rendering the review workflow pane.
    class WorkflowComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super()
      end

      attr_reader :form

      def show_github_deposit?
        Settings.github.enabled
      end

      def show_article_deposit?
        Settings.article_deposit.enabled
      end
    end
  end
end
