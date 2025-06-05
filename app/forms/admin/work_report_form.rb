# frozen_string_literal: true

module Admin
  # Admin form object for generating work reports
  class WorkReportForm < ApplicationForm
    attribute :date_created_start, :date
    attribute :date_created_end, :date
    attribute :date_modified_start, :date
    attribute :date_modified_end, :date
    attribute :collection_ids
    attribute :draft_not_deposited_state, :boolean, default: true
    attribute :pending_review_state, :boolean, default: true
    attribute :returned_state, :boolean, default: true
    attribute :deposit_in_progress_state, :boolean, default: true
    attribute :deposited_state, :boolean, default: true
    attribute :version_draft_state, :boolean, default: true
  end
end
