# frozen_string_literal: true

module Dashboard
  module Show
    # Component for rendering an alert to the user before they have deposited any works.
    class FirstUseAlertComponent < ApplicationComponent
      delegate :support_email, to: :Settings

      def initialize(user:)
        @user = user
        super()
      end

      def render?
        @user.depositor_for.count == 1 && !@user.works.exists?
      end
    end
  end
end
