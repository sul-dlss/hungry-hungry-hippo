# frozen_string_literal: true

# Model for a collection.
# Note that this model does not contain any cocina data.
class Collection < ApplicationRecord
  belongs_to :user
  has_many :works, dependent: :destroy

  # deposit_job_started_at indicates that the job is queued or running.
  # User should be "waiting" until the job is completed.
  def deposit_job_started?
    deposit_job_started_at.present?
  end

  def deposit_job_finished?
    deposit_job_started_at.nil?
  end
end
