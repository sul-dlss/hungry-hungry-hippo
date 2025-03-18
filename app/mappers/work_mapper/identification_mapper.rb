# frozen_string_literal: true

class WorkMapper
  # Maps WorkForm to Cocina identification parameters
  class IdentificationMapper
    def self.call(...)
      new(...).call
    end

    # @param [WorkForm] work_form
    # @param [source_id] source_id
    def initialize(work_form:, source_id:)
      @work_form = work_form
      @source_id = source_id
    end

    # @return [Hash] the Cocina identification parameters
    def call
      {
        sourceId: source_id
      }.tap do |params|
        params[:doi] = doi if doi?
      end
    end

    private

    attr_reader :work_form, :source_id

    delegate :doi, to: :work_form

    def doi?
      # If a work has not yet been registered, the DOI is assigned as part of the registration request.
      # If the work already has a DOI, it should continue to be added here.
      # If the work does not have a DOI, but one should be assigned then it should be added here.
      work_form.persisted? && %w[assigned yes].include?(work_form.doi_option)
    end

    def doi
      Doi.id(druid: work_form.druid)
    end
  end
end
