# frozen_string_literal: true

# Model for a work.
# Note that this model does not contain any cocina data.
class Work < ApplicationRecord
  belongs_to :user
  belongs_to :collection

  # deposit_job_started_at indicates that the job is queued or running.
  # User should be "waiting" until the job is completed.
  def deposit_job_started?
    deposit_job_started_at.present?
  end

  def deposit_job_finished?
    deposit_job_started_at.nil?
  end
end
