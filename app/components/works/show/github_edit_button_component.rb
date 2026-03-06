# frozen_string_literal: true

module Works
  module Show
    # Component for the button to edit GitHub settings.
    class GithubEditButtonComponent < ApplicationComponent
      def initialize(presenter:)
        @presenter = presenter
        super()
      end

      attr_reader :presenter

      def call
        render SdrViewComponents::Elements::ButtonLinkComponent.new(link: edit_polymorphic_path(presenter,
                                                                                                tab: :deposit),
                                                                    label: 'Manage automatic deposits',
                                                                    variant: 'outline-primary')
      end

      def render?
        @presenter&.editable?
      end
    end
  end
end
