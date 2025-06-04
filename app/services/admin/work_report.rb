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
      items = filter_by_state(works)

      # TODO:
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
      # filter to checked checkboxes
      selected_states = work_report_form.attributes.select { |_, value| value == 1 }.keys

      return works if selected_states.empty?

      works.select do |work|
        if selected_states.include?('draft_not_deposited')
          work.first_draft?
          # need to add other states
        end
      end
    end
  end
end
