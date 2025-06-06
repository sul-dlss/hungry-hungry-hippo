# frozen_string_literal: true

module Admin
  # Generate an item report CSV
  class WorkReport
    def self.call(...)
      new(...).call
    end

    def initialize(work_report_form:)
      @work_report_form = work_report_form
    end

    # @return [String] CSV string for the work report
    # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    def call
      @query = Work.all
      filter_by_date_created_start
      filter_by_date_created_end
      filter_by_date_modified_start
      filter_by_date_modified_end
      filter_by_date_last_deposited_start
      filter_by_date_last_deposited_end
      filter_by_collection
      works_druids = @query.pluck(:druid).compact

      @statuses = Sdr::Repository.statuses(druids: works_druids)
      druids = filter_by_state(@statuses)

      @cocina_objects = druids.map { |druid| Dor::Services::Client.object(druid).find }
      work_forms = @cocina_objects.map do |cocina_object|
        # only cocina_object will be used; other arg assignments are irrelevant
        Form::WorkMapper.call(cocina_object:, doi_assigned: true,
                              agree_to_terms: true,
                              version_description: nil, collection: nil)
      end
      # rubocop:enable Metrics/MethodLength, Metrics/AbcSize

      create_csv(work_forms)
    end

    attr_reader :work_report_form

    private

    def filter_by_date_created_start
      return @query if work_report_form.date_created_start.blank?

      @query = @query.where(created_at: work_report_form.date_created_start..)
    end

    def filter_by_date_created_end
      return @query if work_report_form.date_created_end.blank?

      @query = @query.where(created_at: ..work_report_form.date_created_end)
    end

    def filter_by_date_modified_start
      return @query if work_report_form.date_modified_start.blank?

      @query = @query.where(object_updated_at: work_report_form.date_modified_start..)
    end

    def filter_by_date_modified_end
      return @query if work_report_form.date_modified_end.blank?

      @query = @query.where(object_updated_at: ..work_report_form.date_modified_end)
    end

    def filter_by_date_last_deposited_start
      return @query if work_report_form.last_deposited_start.blank?

      @query = @query.where(last_deposited_at: work_report_form.last_deposited_start..)
    end

    def filter_by_date_last_deposited_end
      return @query if work_report_form.last_deposited_end.blank?

      @query = @query.where(last_deposited_at: ..work_report_form.last_deposited_end)
    end

    def filter_by_collection
      # drop the default empty value from the multi-select
      collection_ids = work_report_form.collection_ids.compact_blank
      return @query if collection_ids.empty?

      # filter by collection
      @query = @query.where(collection_id: collection_ids)
    end

    def selected_states
      # filter to checked checkboxes for item state
      work_report_form.attributes.select { |key, value| key.end_with?('state') && value }.keys
    end

    # @param [Array<Sdr::Repository::ObjectVersion::VersionStatus>] statuses
    # @return [Array<String>] druids
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    def filter_by_state(statuses)
      # return all druids if no state selections
      return statuses.map(&:first) if selected_states.empty?

      results = []
      statuses.each do |druid, status|
        selected_states.each do |selected_state|
          case selected_state
          when 'draft_not_deposited_state'
            results << druid if status.first_draft?
          when 'pending_review_state'
            results << druid if Work.find_by(druid:).pending_review?
          when 'returned_state'
            results << druid if Work.find_by(druid:).rejected_review?
          when 'deposit_in_progress_state'
            results << druid if status.accessioning?
          when 'version_draft_state'
            results << druid if status.open?
          when 'deposited_state'
            results << druid if !status.first_draft? && !status.open? && !status.accessioning?
          end
        end
      end.map(&:first) # just druids

      results.uniq
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity

    # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    def create_csv(work_forms)
      headers = ['item title', 'work_id', 'druid', 'state', 'version number', 'owner', 'date created',
                 'date last modified', 'date last deposited', 'release', 'visibility', 'license', 'custom rights',
                 'DOI', 'work type', 'work subtypes', 'collection title', 'collection id']

      CSV.generate(headers: true) do |csv|
        csv << headers

        work_forms.each do |work_form|
          druid = work_form.druid
          work_model = Work.find_by(druid:)
          row = [work_form.title,
                 work_model.id,
                 work_form.druid,
                 state(druid:, status: @statuses[druid]),
                 work_form.version,
                 work_model.user.email_address.delete_suffix(User::EMAIL_SUFFIX),
                 work_model.created_at,
                 work_model.object_updated_at,
                 work_model.last_deposited_at,
                 work_form.release_date,
                 work_form.access,
                 work_form.license,
                 work_form.custom_rights_statement.present? ? 'yes' : 'no',
                 Cocina::Parser.doi_for(cocina_object: @cocina_objects.find do |obj|
                   obj.externalIdentifier == druid
                 end),
                 work_form.work_type,
                 work_form.work_subtypes.present? ? work_form.work_subtypes.join('; ') : nil,
                 work_model.collection.title,
                 work_model.collection_id]
          csv << row
        end
      end
    rescue StandardError => e
      Rails.logger.error("Error generating item report CSV: #{e.message}")
      raise e
    end
    # rubocop:enable Metrics/AbcSize, Metrics/MethodLength

    # @param [String] druid
    # @param [Sdr::Repository::ObjectVersion::VersionStatus] status
    # @return [String] state(s) of the work
    # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    def state(druid:, status:)
      states = []
      states << 'draft_not_deposited' if status.first_draft?
      states << 'pending_review' if Work.find_by(druid:).pending_review?
      states << 'returned' if Work.find_by(druid:).rejected_review?
      states << 'deposit_in_progress' if status.accessioning?
      states << 'version_draft' if status.open?
      states << 'deposited' if !status.first_draft? && !status.open? && !status.accessioning?

      states.join('; ')
    end
    # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  end
end
