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
      @query = Work.all
      filter_by_date_created_start
      filter_by_date_created_end
      filter_by_date_modified_start
      filter_by_date_modified_end
      filter_by_collection
      works_druids = @query.pluck(:druid)

      @statuses = Sdr::Repository.statuses(druids: works_druids)
      druids = filter_by_state(@statuses)

      @cocina_objects = druids.map { |druid| Dor::Services::Client.object(druid).find }
      works = @cocina_objects.map do |cocina_object|
        # only cocina_object will be used; other arg assignments are irrelevant
        Form::WorkMapper.call(cocina_object:, doi_assigned: true,
                              agree_to_terms: true,
                              version_description: nil, collection: nil)
      end

      create_csv(works)
    end

    attr_reader :work_report_form

    private

    def filter_by_date_created_start
      return @query if work_report_form.date_created_start.blank?

      @query.where(created_at: work_report_form.date_created_start..)
    end

    def filter_by_date_created_end
      return @query if work_report_form.date_created_end.blank?

      @query.where(created_at: ..work_report_form.date_created_end)
    end

    def filter_by_date_modified_start
      return @query if work_report_form.date_modified_start.blank?

      @query.where(object_updated_at: work_report_form.date_modified_start..)
    end

    def filter_by_date_modified_end
      return @query if work_report_form.date_modified_end.blank?

      @query.where(object_updated_at: ..work_report_form.date_modified_end)
    end

    def filter_by_collection
      return @query if work_report_form.collection_ids.blank?

      # filter by collection ids
      @query.where(collection_id: work_report_form.collection_ids)
    end

    def selected_states
      # filter to checked checkboxes (the only checkboxes are for item states)
      work_report_form.attributes.select { |key, value| key.end_with?('state') && value }.keys
    end

    # @param [Array<Sdr::Repository::ObjectVersion::VersionStatus>] statuses
    # @return [Array<String>] druids
    def filter_by_state(statuses)
      return statuses.map(&:first) if selected_states.empty?

      # for each version status, check if the work matches any selected state
      statuses.select do |druid, status|
        selected_states.each do |selected_state|
          case selected_state
          when 'draft_not_deposited'
            status.first_draft?
          when 'pending_review'
            Work.find_by(druid:).pending_review?
          when 'returned'
            Work.find_by(druid:).rejected_review?
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
      end.map(&:first) # just druids
    end

    def create_csv(work_forms)
      headers = ['item title', 'work_id', 'druid', 'state', 'version number', 'owner', 'date created',
                 'date last modified', 'release', 'visibility', 'license', 'custom rights', 'DOI', 'work type',
                 'work subtypes', 'collection title', 'collection id']

      CSV.generate(headers: true) do |csv|
        csv << headers

        work_forms.each do |work|
          druid = work.druid
          work_model = Work.find_by(druid:)
          row = [work.title,
                 work.id,
                 work.druid,
                 state(druid:, status: @statuses[druid]),
                 work.version,
                 work_model.user.email_address.delete_suffix(User::EMAIL_SUFFIX),
                 work_model.object_updated_at,
                 work.release_date,
                 work.access,
                 work.license,
                 work.custom_rights_statement.present? ? 'yes' : 'no',
                 Cocina::Parser.doi_for(cocina_object: @cocina_objects.find do |obj|
                   obj.externalIdentifier == druid
                 end),
                 work.work_type,
                 work.work_subtypes.join('; '),
                 work_model.collection.title,
                 work_model.collection_id]
          csv << row
        end
      end
    rescue StandardError => e
      Rails.logger.error("Error generating item report CSV: #{e.message}")
      raise e
    end

    def state(druid:, status:)
      return 'draft_not_deposited' if status.first_draft?
      return 'pending_review' if Work.find_by(druid:).pending_review?
      return 'returned' if Work.find_by(druid:).rejected_review?
      return 'deposit_in_progress' if status.accessioning?
      return 'version_draft' if status.open?
      return 'deposited' if !status.first_draft? && !status.open? && !status.accessioning?

      nil
    end
  end
end
