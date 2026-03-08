# frozen_string_literal: true

module Works
  module Show
    # Component for notifying the user that the work is being deposited.
    class DepositingGithubComponent < ApplicationComponent
      def initialize(work_presenter:)
        @work_presenter = work_presenter
        super()
      end

      def render?
        @work_presenter.github_deposit_enabled && @work_presenter.version_status.first_draft?
      end

      def github_releases_path
        "https://github.com/#{@work_presenter.github_repository_name}/releases"
      end
    end
  end
end
