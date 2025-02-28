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
        render Elements::Forms::SubmitComponent.new(form_id:, label:, classes:, data:)
      end

      def label
        if collection.review_enabled? && (work.nil? || !helpers.allowed_to?(:review?, work))
          'Submit for review'
        else
          'Deposit'
        end
      end
    end
  end
end
