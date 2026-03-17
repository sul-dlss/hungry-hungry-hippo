# frozen_string_literal: true

module ApplicationHelper
  def human_boolean(boolean)
    boolean ? 'Yes' : 'No'
  end

  def terms_of_deposit_modal_link
    link_to('Terms of Deposit', '#', data: { bs_toggle: 'modal', bs_target: '#tod-modal' })
    # <a href="#" data-bs-toggle="modal" data-bs-target="#tod-modal">Terms of Deposit</a>
  end

  # add icons to the end of the work title when rendering for github and article deposits
  def work_title_with_type_icon(work)
    icon = if work.is_a?(GithubRepository)
             github_icon(classes: 'ms-1 text-black', aria: { hidden: true })
           elsif work.is_a?(Article)
             open_access_icon(classes: 'ms-1 text-black', aria: { hidden: true })
           end

    return work.title unless icon

    safe_join([work.title, icon])
  end
end
