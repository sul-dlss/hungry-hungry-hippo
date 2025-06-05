# frozen_string_literal: true

module Admin
  # Admin form object for generating work reports
  class WorkReportForm < ApplicationForm
    include ActiveModel::Attributes

    attribute :date_created_start, :date
    attribute :date_created_end, :date
    attribute :date_modified_start, :date
    attribute :date_modified_end, :date
    attribute :collection_ids
    attribute :draft_not_deposited_state, :string, default: '0'
    attribute :pending_review_state, :string, default: '0'
    attribute :returned_state, :string, default: '0'
    attribute :deposit_in_progress_state, :string, default: '0'
    attribute :deposited_state, :string, default: '0'
    attribute :version_draft_state, :string, default: '0'
  end
end
