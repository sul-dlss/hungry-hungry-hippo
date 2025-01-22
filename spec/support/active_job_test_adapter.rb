# frozen_string_literal: true

# Uses active job test adapter when configured with :active_job_test_adapter
RSpec.configure do |config|
  config.around(:example, :active_job_test_adapter) do |example|
    ActiveJob::Base.queue_adapter = :test
    example.run
    ActiveJob::Base.queue_adapter = :inline
  end
end
