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
      # query H3 by the params and get works
      works

      # query DSA by druids to get cocina
      # parse cocina into CSV
      # mail the result
    end

    attr_reader :work_report_form

    private

    def works
      Work.where(
        date_created: work_report_form.date_created_start..work_report_form.date_created_end,
        date_modified: work_report_form.date_modified_start..work_report_form.date_modified_end,
        collection_id: work_report_form.collection_ids
      ).pluck(:druid, :title, :created_at, :date_modified, :state)
    end

    def filter_by_state
      return works if work_report_form.states.empty?

      work_report_form.state&.split(',') || []
    end
  end
end
