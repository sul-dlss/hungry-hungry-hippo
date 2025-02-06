# frozen_string_literal: true

module Structure
  # Component for rendering the contact form, can be used as a page or in a modal
  class ContactFormComponent < ApplicationComponent
    def initialize(modal: false)
      @modal = modal
      super()
    end

    private

    def modal?
      @modal
    end

    def cancel_button_params
      return modal_dismiss_params if modal?

      back_to_root_params
    end

    def modal_dismiss_params
      {
        data: { bs_dismiss: 'modal' },
        classes: 'me-2',
        link: '#'
      }
    end

    def back_to_root_params
      {
        classes: 'me-2',
        link: helpers.root_path
      }
    end
  end
end
