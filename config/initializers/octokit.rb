# frozen_string_literal: true

# Swap out the default retry strategy for Octokit.
retry_index = Octokit.middleware.handlers.index { |middleware| middleware.inspect == 'Faraday::Retry::Middleware' }
raise 'Octokit retry middleware not found' unless retry_index

retry_exceptions = Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS + [Octokit::ServerError, Faraday::ConnectionFailed]
Octokit.middleware.swap retry_index, Faraday::Retry::Middleware, exceptions: retry_exceptions, max: 6, interval: 0.5,
                                                                 backoff_factor: 2
