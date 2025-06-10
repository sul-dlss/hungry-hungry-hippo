# frozen_string_literal: true

module Admin
  # Admin form object for generating work reports
  class WorkReportForm < ApplicationForm
    attribute :date_created_start, :date
    attribute :date_created_end, :date
    attribute :date_modified_start, :date
    attribute :date_modified_end, :date
    attribute :last_deposited_start, :date
    attribute :last_deposited_end, :date
    attribute :collection_ids, array: true
    attribute :draft_not_deposited_state, :boolean, default: false
    attribute :pending_review_state, :boolean, default: false
    attribute :returned_state, :boolean, default: false
    attribute :deposit_in_progress_state, :boolean, default: false
    attribute :deposited_state, :boolean, default: false
    attribute :version_draft_state, :boolean, default: false
  end
end
