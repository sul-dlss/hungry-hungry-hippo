# frozen_string_literal: true

# Swap out the default retry strategy for Octokit.
retry_index = Octokit.middleware.handlers.index { |middleware| middleware.inspect == 'Faraday::Retry::Middleware' }
raise 'Octokit retry middleware not found' unless retry_index

retry_exceptions = Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS +
                   [Octokit::ServerError, Faraday::ConnectionFailed, Faraday::SSLError]
retry_block = lambda do |env:, _options:, retry_count:, exception:, will_retry_in:|
  Rails.logger.info("Octokit retrying #{env.method.upcase} #{env.url} for #{exception.class}: #{exception.message}. " \
                    "Retry count: #{retry_count}, will retry in #{will_retry_in} seconds.")
end
Octokit.middleware.swap retry_index, Faraday::Retry::Middleware, exceptions: retry_exceptions,
                                                                 max: 10,
                                                                 interval: 1,
                                                                 backoff_factor: 2,
                                                                 retry_statuses: [502],
                                                                 methods: %i[get post head options delete put],
                                                                 retry_block:
