# frozen_string_literal: true

module Articles
  module Edit
    # Component for rendering the extracted abstract.
    class ExtractedAbstractComponent < ApplicationComponent
      def initialize(form:, abstract:, doi:)
        @form = form
        @abstract = abstract
        @doi = doi
        super()
      end

      attr_reader :form, :abstract, :doi
    end
  end
end
