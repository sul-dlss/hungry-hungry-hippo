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

      delegate :sunetid, :name, to: :object

      delegate :object, to: :form

      def lookup_id
        form.field_id(:lookup)
      end

      def label
        'SUNet ID'
      end

      def value
        return unless sunetid

        "#{sunetid}: #{name}"
      end
    end
  end
end
