# frozen_string_literal: true

module Admin
  # Admin form object for generating collection reports
  class CollectionReportForm < ApplicationForm
    attribute :date_created_start, :date
    attribute :date_created_end, :date
    attribute :date_modified_start, :date
    attribute :date_modified_end, :date
  end
end
