# frozen_string_literal: true

# SolidQueue does not auto-retry jobs so we use ActiveJob to accomplish the same thing.
class RetriableJob < ApplicationJob
  # This includes the first run plus all retries
  MAX_ATTEMPTS = 5

  # Retriable jobs should retry when any exception is raised. Retry
  # `MAX_ATTEMPTS` times, and use exponential backoff so that the attempts are
  # spread across a span of roughly ten minutes.
  #
  # If the number of attempts hits the max, log and alert that this has happened.
  retry_on StandardError, attempts: MAX_ATTEMPTS,
                          wait: ->(executions) { (executions**4) + (Kernel.rand * (executions**3)) + 2 } do |job, error|
    # We're out of retries
    Rails.logger.error(
      "Job #{job.job_id} was failed after #{MAX_ATTEMPTS} runs due to #{error.class}: #{error.message}"
    )
    Honeybadger.context(job_id: job.job_id, attempts: MAX_ATTEMPTS)
    raise error
  end
end
