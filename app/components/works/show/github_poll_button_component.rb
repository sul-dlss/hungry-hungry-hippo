# frozen_string_literal: true

module Works
  module Show
    # Component for the button to poll GitHub for new releases.
    class GithubPollButtonComponent < ApplicationComponent
      def initialize(work:, **args)
        @work = work
        @args = args
        super()
      end

      attr_reader :work, :args

      def call
        render Elements::ButtonFormComponent.new(link: poll_github_repository_path(work),
                                                 label: 'Check for new GitHub releases',
                                                 variant: 'outline-primary', method: :post,
                                                 top: true,
                                                 **args)
      end

      def render?
        work.is_a?(GithubRepository) && work.github_deposit_enabled
      end
    end
  end
end
