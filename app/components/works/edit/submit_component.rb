# frozen_string_literal: true

module Works
  module Edit
    # Component for rendering a submit button
    class SubmitComponent < ApplicationComponent
      def initialize(work:, collection:, form_id: nil, classes: [], data: {})
        @form_id = form_id
        @work = work
        @collection = collection
        @classes = classes
        @data = data
        super()
      end

      attr_reader :form_id, :work, :collection, :classes, :data

      def call
        render SdrViewComponents::Forms::SubmitComponent.new(form_id:, label:, classes:, data:)
      end

      def render?
        review_permissions? || deposit_permissions?
      end

      def label
        if collection.review_enabled? && !review_permissions?
          'Submit for review'
        else
          'Deposit'
        end
      end

      def review_permissions?
        @review_permissions ||= helpers.allowed_to?(:review?, collection)
      end

      def deposit_permissions?
        helpers.allowed_to?(:deposit?, work || collection, with: WorkPolicy)
      end
    end
  end
end
