# frozen_string_literal: true

module Works
  module Edit
    # Component for rendering the access settings pane.
    class AccessSettingsComponent < ApplicationComponent
      def initialize(form:, collection:)
        @form = form
        @collection = collection
        super()
      end

      attr_reader :form

      delegate :depositor_selects_access?, :max_release_date, :immediate_release_option?, to: :@collection

      def access_options
        [
          [I18n.t('access.stanford'), 'stanford'],
          [I18n.t('access.world'), 'world']
        ]
      end

      def collection_selects_access_message
        access_text = form.object.access == 'stanford' ? 'the Stanford Community' : 'anyone'
        "The files in your deposit will be downloadable by #{access_text}."
      end

      def min_release_date
        Time.zone.today
      end

      def datepicker_help_text
        "Date must be before #{max_release_date.strftime('%B %d, %Y')}"
      end
    end
  end
end
