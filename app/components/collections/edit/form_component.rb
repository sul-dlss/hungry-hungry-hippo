# frozen_string_literal: true

module Collections
  module Edit
    # Component for the Collection edit form.
    class FormComponent < ApplicationComponent
      def initialize(collection_form:)
        @collection_form = collection_form
        super()
      end
    end
  end
end
