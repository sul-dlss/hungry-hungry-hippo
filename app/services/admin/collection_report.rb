# frozen_string_literal: true

module Admin
  # Generate a collection report CSV
  class CollectionReport
    HEADERS = ['collection title',
               'collection_id',
               'collection druid',
               'owner',
               'managers',
               'date created',
               'date last modified',
               'release setting',
               'release duration',
               'visibility setting',
               'license setting',
               'license',
               'custom rights allowed',
               'custom rights provided',
               'custom rights instructions',
               'DOI yes/no',
               'review workflow',
               'works count',
               'deposited count',
               'first draft count',
               'draft count',
               'pending review',
               'returned review'].freeze

    def self.call(...)
      new(...).call
    end

    def initialize(collection_report_form:)
      @collection_report_form = collection_report_form
    end

    # Generate a collection report CSV based on the provided filters in the collection report form.
    # If no selections are made on the the form, all collections will be included in the report.
    # @return [String] CSV string for the collection report
    def call
      CSV.generate(headers: true) do |csv|
        csv << HEADERS
        collections = QueryBuilder.call(collection_report_form:)

        collections.find_each do |collection|
          collection_row = CollectionRow.new(collection:)
          csv << collection_row.to_row
        end
      end
    end

    attr_reader :collection_report_form

    # Builds a query based on the filters provided in the collection report form.
    class QueryBuilder
      def self.call(...)
        new(...).call
      end

      def initialize(collection_report_form:)
        @collection_report_form = collection_report_form
        @query = Collection.where.not(druid: nil).order(:druid)
      end

      def call
        filter_by_date_created_start
        filter_by_date_created_end
        filter_by_date_modified_start
        filter_by_date_modified_end

        query
      end

      private

      attr_reader :collection_report_form, :query

      def filter_by_date_created_start
        return if collection_report_form.date_created_start.blank?

        @query = query.where(created_at: collection_report_form.date_created_start..)
      end

      def filter_by_date_created_end
        return if collection_report_form.date_created_end.blank?

        @query = query.where(created_at: ..collection_report_form.date_created_end)
      end

      def filter_by_date_modified_start
        return if collection_report_form.date_modified_start.blank?

        @query = query.where(object_updated_at: collection_report_form.date_modified_start..)
      end

      def filter_by_date_modified_end
        return if collection_report_form.date_modified_end.blank?

        @query = query.where(object_updated_at: ..collection_report_form.date_modified_end)
      end
    end

    # Represents a single row in the collection report CSV.
    class CollectionRow
      def initialize(collection:)
        @collection = collection
      end

      def to_row # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        [
          collection_form.title,
          collection.id,
          druid,
          collection.user.sunetid,
          managers,
          collection.created_at,
          collection.object_updated_at,
          collection.release_option,
          collection.release_duration,
          collection_presenter.visibility,
          collection.license_option,
          collection_presenter.license_label,
          collection_presenter.custom_rights_allowed,
          collection_presenter.custom_rights_provided,
          collection_presenter.custom_rights_statement_instructions_provided,
          collection.doi_option,
          collection.review_enabled,
          collection.works.count,
          deposit_stats.fetch('Deposited', 0),
          deposit_stats.fetch('Draft - Not deposited', 0),
          deposit_stats.fetch('New version in draft', 0),
          collection.works.count(&:pending_review?),
          collection.works.count(&:rejected_review?)
        ]
      end

      private

      attr_reader :collection

      delegate :druid, to: :collection

      def cocina_object
        @cocina_object ||= Sdr::Repository.find(druid:)
      end

      def collection_form
        # only cocina_object will be used; other arg assignments are irrelevant
        @collection_form ||= Form::CollectionMapper.call(cocina_object:, collection:)
      end

      def version_status
        @version_status = Sdr::Repository.status(druid:)
      end

      def collection_presenter
        @collection_presenter ||= CollectionPresenter.new(collection:, collection_form:, version_status:)
      end

      def managers
        collection.managers.map(&:sunetid).join(', ')
      end

      def deposit_stats
        @deposit_stats ||= collection.works.where.not(druid: nil).filter_map do |work|
          Sdr::Repository.status(druid: work.druid).status_message
        rescue Sdr::Repository::NotFoundResponse => e
          Honeybadger.notify('Error looking up work in SDR. This may be a draft work that was purged via Argo.',
                             context: {
                               collection_druid: collection.druid,
                               work_druid: work.druid,
                               exception: e
                             })
          nil
        end.compact
           .group_by(&:itself).transform_values(&:count)
      end
    end
  end
end
