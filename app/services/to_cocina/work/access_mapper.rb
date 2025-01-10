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
          license: license.presence,
          useAndReproductionStatement: I18n.t('license.terms_of_use')
        }.merge(access_params).compact
      end

      private

      attr_reader :work_form

      delegate :access, :license, :release_option, :release_date, to: :work_form

      def access_params
        return access_params_with_embargo if release_option == 'delay'

        {
          view: access,
          download: access
        }
      end

      def access_params_with_embargo
        {
          view: 'citation-only',
          download: 'none',
          embargo:
        {
          view: access,
          download: access,
          releaseDate: release_date.to_datetime.iso8601
        }
        }
      end
    end
  end
end
