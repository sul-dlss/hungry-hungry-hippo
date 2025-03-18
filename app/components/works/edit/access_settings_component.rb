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

      delegate :depositor_selects_access?, to: :@collection

      def immediate_release_option?
        # In cases in which the collection previously allowed the user to select an embargo date
        # and the work has an embargo date, but the collection is now immediate release the work
        # can keep the embargo date.
        return false if form.object.release_option == 'delay'

        @collection.immediate_release_option?
      end

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
        "Date must be before #{max_release_date&.strftime('%B %d, %Y')}"
      end

      def delay_release_option_label
        fixed_release_date? ? "On #{form.object.release_date}" : 'On this date'
      end

      def fixed_release_date?
        form.object.release_option == 'delay' && @collection.immediate_release_option?
      end

      def max_release_date
        form.object.max_release_date
      end
    end
  end
end
