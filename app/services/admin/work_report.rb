# frozen_string_literal: true

module Admin
  # Generate an item report CSV
  class WorkReport
    HEADERS = ['item title', 'work_id', 'druid', 'deposit state', 'review state', 'version number', 'owner',
               'date created', 'date last modified', 'date last deposited', 'release', 'visibility',
               'license', 'custom rights', 'DOI', 'work type', 'work subtypes',
               'total number of files', 'total file size (kb)',
               'collection title', 'collection id', 'collection_druid'].freeze

    def self.call(...)
      new(...).call
    end

    def initialize(work_report_form:)
      @work_report_form = work_report_form
    end

    # Generate a work report CSV based on the provided filters in the work report form.
    # If no selections are made on the the form, all works will be included in the report.
    # @return [String] CSV string for the work report
    def call
      CSV.generate(headers: true) do |csv|
        csv << HEADERS
        works = QueryBuilder.call(work_report_form:)

        works.find_each do |work|
          work_row = WorkRow.new(work:)
          # skip if there was an error looking up the work in SDR
          next if work_row.to_row.blank?
          next unless select_by_states?(work_row:)

          csv << work_row.to_row
          work_row.cleanup!
        end
      end
    end

    attr_reader :work_report_form

    private

    # @return [boolean] true if the work row should be selected based on its states
    def select_by_states?(work_row:) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity
      # If no states are selected, then select.
      return true if work_form_selected_states.empty?

      work_form_selected_states.any? do |selected_state|
        case selected_state
        when 'draft_not_deposited_state'
          work_row.version_status_message == 'Draft - Not deposited'
        when 'version_draft_state'
          work_row.version_status_message == 'New version in draft'
        when 'deposit_in_progress_state'
          work_row.version_status_message == 'Depositing'
        when 'deposited_state'
          work_row.version_status_message == 'Deposited'
        when 'pending_review_state'
          work_row.review_message == 'Pending review'
        when 'returned_state'
          work_row.review_message == 'Returned'
        end
      end
    end

    def work_form_selected_states
      # filter to checked checkboxes for item state
      @work_form_selected_states ||= work_report_form.attributes.select do |key, value|
        key.end_with?('state') && value
      end.keys
    end

    # Builds a query based on the filters provided in the work report form.
    class QueryBuilder
      def self.call(...)
        new(...).call
      end

      def initialize(work_report_form:)
        @work_report_form = work_report_form
        @query = Work.where.not(druid: nil).order(:druid)
      end

      def call
        filter_by_date_created_start
        filter_by_date_created_end
        filter_by_date_modified_start
        filter_by_date_modified_end
        filter_by_date_last_deposited_start
        filter_by_date_last_deposited_end
        filter_by_collection

        query
      end

      private

      attr_reader :work_report_form, :query

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
    end

    # Represents a single row in the work report CSV.
    class WorkRow
      def initialize(work:)
        @work = work
      end

      def to_row # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        [
          work_form.title,
          work.id,
          work_form.druid,
          version_status_message,
          review_message,
          work_form.version,
          work.user.sunetid,
          work.created_at,
          work.object_updated_at,
          work.last_deposited_at,
          work_form.release_date,
          work_form.access,
          work_form.license,
          work_form.custom_rights_statement.present? ? 'yes' : 'no',
          work.doi_assigned? ? Doi.url(druid:) : nil,
          work_form.work_type,
          work_form.work_subtypes.present? ? work_form.work_subtypes.join('; ') : nil,
          content.content_files.count,
          content.content_files.sum(&:size) / 1000.0, # size is in bytes, convert to kb (decimal)
          work.collection.title,
          work.collection_id,
          work.collection.druid
        ]
      rescue Sdr::Repository::NotFoundResponse => e
        Honeybadger.notify('Error looking up work in SDR. This may be a draft work that was purged via Argo.',
                           context: {
                             druid:,
                             exception: e
                           })
        nil
      end

      def cleanup!
        content.destroy!
      end

      delegate :version_status_message, :review_message, to: :presenter

      private

      attr_reader :work

      delegate :druid, to: :work

      def cocina_object
        @cocina_object ||= Sdr::Repository.find(druid:)
      end

      def work_form
        # only cocina_object will be used; other arg assignments are irrelevant
        @work_form ||= Form::WorkMapper.call(cocina_object:, doi_assigned: true, agree_to_terms: true,
                                             version_description: nil, collection: nil)
      end

      def content
        @content ||= Contents::Builder.call(cocina_object:, user: work.user, work:)
      end

      def presenter
        @presenter ||= WorkPresenter.new(work:, work_form:, version_status:)
      end

      def version_status
        @version_status ||= Sdr::Repository.status(druid:)
      end
    end
  end
end
