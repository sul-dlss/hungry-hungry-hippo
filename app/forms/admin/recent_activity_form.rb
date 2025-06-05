# frozen_string_literal: true

module Admin
  # Admin form object for selecting recent activity days limit.
  class RecentActivityForm < ApplicationForm
    attribute :type, :string
    attribute :days_limit, :string

    # Days limit options for recent activity.
    DAYS_LIMIT_OPTIONS = { '1 day': '1',
                           '7 days': '7',
                           '14 days': '14',
                           '30 days': '30',
                           '365 days': '365' }.freeze
  end
end
