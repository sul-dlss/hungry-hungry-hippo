# frozen_string_literal: true

module Articles
  module Edit
    # Component for rendering the extracted abstract.
    class ExtractedAbstractComponent < ApplicationComponent
      def initialize(form:, abstract:, doi:, content_id:)
        @form = form
        @abstract = abstract
        @doi = doi
        @content_id = content_id
        super()
      end

      attr_reader :form, :abstract, :doi, :content_id
    end
  end
end
