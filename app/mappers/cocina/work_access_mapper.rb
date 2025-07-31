# frozen_string_literal: true

# The containing namespace for mappers indicates what is being mapped *to*
module Cocina
  # Maps WorkForm to Cocina access parameters
  class WorkAccessMapper
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
        useAndReproductionStatement: TermsOfUseSupport.full_statement(custom_rights_statement:),
        copyright:
      }.merge(access_params).compact
    end

    private

    attr_reader :work_form

    delegate :access, :release_option, :release_date, :custom_rights_statement, :copyright, to: :work_form

    def access_params
      return access_params_with_embargo if release_option == 'delay' && release_date.present?

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

    def license
      return nil if work_form.license.blank? || work_form.license == License::NO_LICENSE_ID

      work_form.license
    end
  end
end
