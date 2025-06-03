# frozen_string_literal: true

module Admin
  # Admin form object for generating work reports
  class WorkReportForm < ApplicationForm
    include ActiveModel::Attributes
    attribute :date_created_start, :date
    attribute :date_created_end, :date
    attribute :date_modified_start, :date
    attribute :date_modified_end, :date
    attribute :collection_ids, default: []
    attribute :state, :string
  end
end
