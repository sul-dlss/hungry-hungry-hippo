# frozen_string_literal: true

module Github
  # Service for handling GitHub application interactions.
  class AppService
    private

    def client
      @client ||= if Rails.env.development?
                    Octokit::Client.new
                  else
                    Octokit::Client.new(client_id: Settings.github.client_id,
                                        client_secret: Settings.github.client_secret)
                  end
    end
  end
end
