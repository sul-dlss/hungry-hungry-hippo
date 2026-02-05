# frozen_string_literal: true

module Admin
  # Return a list of depositors based on druids
  class DepositorsSearch
    def self.call(...)
      new(...).call
    end

    # @param [Admin::DepositorsSearchForm] form an instance of the depositors search form
    def initialize(form:)
      @druid_list = form.druid_list
    end

    # @return [Array<Hash{Symbol => String, Array<String>}>] an array of key-value
    #   pairs corresponding to work DRUIDs and work depositor SUNet IDs, a data
    #   structure used by, e.g., the `with_rows` slot of the `Elements::Tables::TableComponent`
    def call
      selected_works.map do |work|
        {
          id: work.druid,
          values: [work.druid, work.email_address.delete_suffix(User::EMAIL_SUFFIX)]
        }
      end
    end

    private

    attr_reader :druid_list

    def selected_works
      # iterate over the druids so we can preserve the order the user entered them in the results
      # see https://github.com/sul-dlss/hungry-hungry-hippo/issues/1786
      druid_list.map do |druid|
        Work.joins(:user).select('works.druid, works.user_id, users.email_address').find_by(druid:)
      end
    end
  end
end
