# frozen_string_literal: true

module Works
  module Edit
    # Component for rendering a submit button
    class SubmitComponent < ApplicationComponent
      def initialize(work:, collection:, form_id: nil, classes: [], data: {}, deposit_label: 'Deposit') # rubocop:disable Metrics/ParameterLists
        @form_id = form_id
        @work = work
        @collection = collection
        @classes = classes
        @data = data
        @deposit_label = deposit_label
        super()
      end

      attr_reader :form_id, :work, :collection, :classes, :data, :deposit_label

      def call
        render Elements::Forms::SubmitComponent.new(form_id:, label:, classes:, data:, value:)
      end

      def render?
        review_permissions? || deposit_permissions?
      end

      def label
        if review?
          'Submit for review'
        else
          deposit_label
        end
      end

      def value
        review? ? 'review' : 'deposit'
      end

      def review?
        collection.review_enabled? && !review_permissions?
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
