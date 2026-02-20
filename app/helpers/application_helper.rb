# frozen_string_literal: true

module ApplicationHelper
  def human_boolean(boolean)
    boolean ? 'Yes' : 'No'
  end

  def terms_of_deposit_modal_link
    link_to('Terms of Deposit', '#', data: { bs_toggle: 'modal', bs_target: '#tod-modal' })
    # <a href="#" data-bs-toggle="modal" data-bs-target="#tod-modal">Terms of Deposit</a>
  end
end
