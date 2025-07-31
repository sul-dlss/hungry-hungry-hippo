# frozen_string_literal: true

module Works
  module Edit
    # Component for rendering the DOI form
    class DoiComponent < ApplicationComponent
      def initialize(form:, collection:)
        @form = form
        @collection = collection
        super()
      end

      attr_reader :form

      delegate :yes_doi_option?, :no_doi_option?, to: :@collection

      def assigned?
        form.object.doi_option == 'assigned'
      end

      def doi_link
        link_to(nil, Doi.url(druid: form.object.druid))
      end

      def altmetric_link
        Settings.altmetric_url
      end
    end
  end
end
