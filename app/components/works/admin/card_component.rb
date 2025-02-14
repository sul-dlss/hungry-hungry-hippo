# frozen_string_literal: true

module Works
  module Admin
    # Renders card for admin functions.
    class CardComponent < ApplicationComponent
      def initialize(work_presenter:)
        @work_presenter = work_presenter
        super
      end

      def render?
        helpers.allowed_to?(:show?, with: AdminPolicy) && options.present?
      end

      def options
        @options ||= [].tap do |options|
          if @work_presenter.editable?
            options << ['Move to another collection',
                        new_work_admin_move_path(@work_presenter.druid, content_id: @work_presenter.content_id)]
          end
        end
      end
    end
  end
end
