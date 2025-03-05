# frozen_string_literal: true

module Collections
  module Edit
    # Component for editing collection contributors
    class ParticipantComponent < ApplicationComponent
      def initialize(form:)
        @form = form
        super()
      end

      attr_reader :form

      def value?
        form.object.sunetid.present?
      end

      def lookup_id
        form.field_id(:lookup)
      end

      def label
        'SUNet ID'
      end
    end
  end
end
