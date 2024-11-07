# frozen_string_literal: true

module ApplicationCable
  # Action Cable connection for the application.
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      # Reject unless there is a signed cookie with the user id.
      set_current_user || reject_unauthorized_connection
    end

    private

    def set_current_user
      return unless (user = User.find_by(id: cookies.signed[:user_id]))

      self.current_user = user
    end
  end
end
