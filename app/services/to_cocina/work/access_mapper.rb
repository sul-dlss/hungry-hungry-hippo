# frozen_string_literal: true

module ToCocina
  module Work
    # Maps WorkForm to Cocina access parameters
    class AccessMapper
      def self.call(...)
        new(...).call
      end

      # @param [WorkForm] work_form
      def initialize(work_form:)
        @work_form = work_form
      end

      # @return [Hash] the Cocina access parameters
      def call
        {
          view: access,
          download: access,
          license: license.presence,
          useAndReproductionStatement: I18n.t('license.terms_of_use')
        }.compact
      end

      private

      attr_reader :work_form

      delegate :access, :license, to: :work_form
    end
  end
end
