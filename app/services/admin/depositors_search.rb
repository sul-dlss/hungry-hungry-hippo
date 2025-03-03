# frozen_string_literal: true

module Admin
  # Return a list of depositors based on druids
  class DepositorsSearch
    def self.call(...)
      new(...).call
    end

    def initialize(form:)
      @form = form
    end

    def call
      form.druid_list.map do |druid|
        work = Work.find_by!(druid:)

        {
          id: druid,
          values: [druid, work.user.sunetid]
        }
      end
    end

    private

    attr_reader :form
  end
end
