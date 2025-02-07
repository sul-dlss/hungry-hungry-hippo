# frozen_string_literal: true

module Structure
  # Component for rendering the contact form response
  class ContactFormSuccessComponent < ApplicationComponent
    def initialize(modal: false)
      @modal = modal
      super()
    end

    private

    def modal?
      @modal
    end

    def close_button_params
      return { data: { bs_dismiss: 'modal' }, link: '#', label: 'Close', variant: :link } if modal?

      { link: root_path, target: '_top', label: 'Close', variant: :link }
    end

    def turbo_frame_id
      modal? ? 'contact-form' : 'welcome-form'
    end
  end
end
