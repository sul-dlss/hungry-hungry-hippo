# frozen_string_literal: true

module Admin
  # Generate an item report
  class WorkReport
    def self.call(...)
      new(...).call
    end

    def initialize(work_report_form:)
      @work_report_form = work_report_form
    end

    def call
      # query works by data/collection params and get version statuses
      statuses = Sdr::Repository.statuses(druids: works_subset_druids)
      druids = filter_by_state(statuses)

      cocina_objects = druids.map { |druid| Dor::Services::Client.object(druid).find }
      cocina_objects.map do |cocina_object|
        Form::WorkMapper.call(cocina_object:, doi_assigned: true,
                              agree_to_terms: true,
                              version_description: nil, collection: nil)
      end

      # TODO:
      # any additional parsing of cocina into CSV
      # mail the result (put this in the job)
    end

    attr_reader :work_report_form

    private

    # finds works that match the form's date and collection criteria
    # @return [Array<String>] druids
    def works_subset_druids
      Work.where(
        created_at: work_report_form.date_created_start..work_report_form.date_created_end,
        object_updated_at: work_report_form.date_modified_start..work_report_form.date_modified_end,
        collection_id: work_report_form.collection_ids
      ).pluck(:druid)
    end

    def selected_states
      # filter to checked checkboxes (the only checkboxes are for item states)
      work_report_form.attributes.select { |key, value| key.end_with?('state') && value == '1' }.keys
    end

    # @param [Array<Sdr::Repository::ObjectVersion::VersionStatus>] statuses
    # @return [Array<String>] druids
    def filter_by_state(statuses)
      return statuses.map(&:first) if selected_states.empty?

      # for each version status, check if the work matches any selected state
      statuses.select do |status|
        selected_states.each do |selected_state|
          case selected_state
          when 'draft_not_deposited'
            status.first_draft?
          when 'pending_review'
            status.work.pending_review?
          when 'returned'
            status.work.rejected_review?
          when 'deposit_in_progress'
            status.accessioning?
          when 'version_draft'
            status.open?
          when 'deposited'
            !status.first_draft? && !status.open? && !status.accessioning?
          else
            false
          end
        end
      end.map(&:first)
    end
  end
end
