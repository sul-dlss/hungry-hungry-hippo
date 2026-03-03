# frozen_string_literal: true

module Articles
  module Edit
    # Component for rendering the extracted abstract.
    class ExtractedAbstractComponent < ApplicationComponent
      def initialize(form:, abstract:)
        @form = form
        @abstract = abstract
        super()
      end

      attr_reader :form, :abstract
    end
  end
end
