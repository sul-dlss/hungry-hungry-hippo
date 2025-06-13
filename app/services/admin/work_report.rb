# frozen_string_literal: true

module Admin
  # Generate an item report CSV
  class WorkReport
    def self.call(...)
      new(...).call
    end

    def initialize(work_report_form:)
      @work_report_form = work_report_form
      # Sorting makes this deterministic for testing.
      @query = Work.order(:druid)
    end

    # Generate a work report CSV based on the provided filters in the work report form.
    # If no selections are made on the the form, all works will be included in the report.
    # @return [String] CSV string for the work report
    def call
      filter_by_date_created_start
      filter_by_date_created_end
      filter_by_date_modified_start
      filter_by_date_modified_end
      filter_by_date_last_deposited_start
      filter_by_date_last_deposited_end
      filter_by_collection
      filter_by_states

      create_csv
    end

    attr_reader :work_report_form
    attr_accessor :query

    private

    def filter_by_date_created_start
      return if work_report_form.date_created_start.blank?

      @query = query.where(created_at: work_report_form.date_created_start..)
    end

    def filter_by_date_created_end
      return if work_report_form.date_created_end.blank?

      @query = query.where(created_at: ..work_report_form.date_created_end)
    end

    def filter_by_date_modified_start
      return if work_report_form.date_modified_start.blank?

      @query = query.where(object_updated_at: work_report_form.date_modified_start..)
    end

    def filter_by_date_modified_end
      return if work_report_form.date_modified_end.blank?

      @query = query.where(object_updated_at: ..work_report_form.date_modified_end)
    end

    def filter_by_date_last_deposited_start
      return if work_report_form.last_deposited_start.blank?

      @query = query.where(last_deposited_at: work_report_form.last_deposited_start..)
    end

    def filter_by_date_last_deposited_end
      return if work_report_form.last_deposited_end.blank?

      @query = query.where(last_deposited_at: ..work_report_form.last_deposited_end)
    end

    def filter_by_collection
      # drop the default empty value from the multi-select
      collection_ids = work_report_form.collection_ids.compact_blank
      return if collection_ids.empty?

      # filter by collection
      @query = query.where(collection_id: collection_ids)
    end

    # Filter druids by the selected states in the work report form
    # @return [Array<string>] druids filtered by the selected states
    def filter_by_states
      # If no states are selected, return all druids.
      return if selected_states.empty?

      @druids = druids.select { |druid| selected_states?(druid) }
    end

    # Check if the work's version state and review state match any of the selected states
    # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength
    def selected_states?(druid)
      version_state = states.dig(druid, :version_state)
      review_state = states.dig(druid, :review_state)
      matching = selected_states.select do |selected_state|
        case selected_state
        when 'draft_not_deposited_state'
          version_state == 'Draft - Not deposited'
        when 'version_draft_state'
          version_state == 'New version in draft'
        when 'deposit_in_progress_state'
          version_state == 'Depositing'
        when 'deposited_state'
          version_state == 'Deposited'
        when 'pending_review_state'
          review_state == 'Pending review'
        when 'returned_state'
          review_state == 'Returned'
        end
      end
      matching.any?
    end
    # rubocop:enable Metrics/CyclomaticComplexity, Metrics/MethodLength

    def druids
      @druids ||= query.pluck(:druid).compact
    end

    def selected_states
      # filter to checked checkboxes for item state
      work_report_form.attributes.select { |key, value| key.end_with?('state') && value }.keys
    end

    # Get the states of works based on version status and work review state
    # @return [Hash] druids and their version and review states
    def states
      @states ||= statuses.to_h do |druid, version_status|
        work_form = work_forms.select { |work| work.druid == druid }
        work = Work.find_by(druid:)
        presenter = WorkPresenter.new(work:, work_form:, version_status:)
        [druid, { version_state: presenter.version_status_message, review_state: presenter.review_message }]
      end
    end

    def statuses
      @statuses ||= Sdr::Repository.statuses(druids:)
    end

    def work_forms
      @work_forms ||= druids.map do |druid|
        cocina_object = Sdr::Repository.find(druid:)
        # only cocina_object will be used; other arg assignments are irrelevant
        Form::WorkMapper.call(cocina_object:, doi_assigned: true, agree_to_terms: true, version_description: nil,
                              collection: nil)
      end
    end

    # rubocop:disable Metrics/AbcSize, Metrics/BlockLength, Metrics/MethodLength
    def create_csv
      headers = ['item title', 'work_id', 'druid', 'deposit state', 'review state', 'version number', 'owner',
                 'date created', 'date last modified', 'date last deposited', 'release', 'visibility',
                 'license', 'custom rights', 'DOI', 'work type', 'work subtypes', 'collection title',
                 'collection id', 'collection_druid']

      CSV.generate(headers: true) do |csv|
        csv << headers

        work_forms.each do |work_form|
          druid = work_form.druid
          next unless druids.include?(druid)

          work_model = Work.find_by(druid:)
          row = [work_form.title,
                 work_model.id,
                 work_form.druid,
                 states[druid][:version_state],
                 states[druid][:review_state],
                 work_form.version,
                 work_model.user.sunetid,
                 work_model.created_at,
                 work_model.object_updated_at,
                 work_model.last_deposited_at,
                 work_form.release_date,
                 work_form.access,
                 work_form.license,
                 work_form.custom_rights_statement.present? ? 'yes' : 'no',
                 work_model.doi_assigned? ? Doi.url(druid:) : nil,
                 work_form.work_type,
                 work_form.work_subtypes.present? ? work_form.work_subtypes.join('; ') : nil,
                 work_model.collection.title,
                 work_model.collection_id,
                 work_model.collection.druid]
          csv << row
        end
      end
    end
    # rubocop:enable Metrics/AbcSize, Metrics/BlockLength, Metrics/MethodLength
  end
end
