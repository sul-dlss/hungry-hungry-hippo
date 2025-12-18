# frozen_string_literal: true

module ApplicationHelper
  def human_boolean(boolean)
    boolean ? 'Yes' : 'No'
  end

  # Returns work title with GitHub icon if the work is linked to a GitHub repository
  def work_title_with_github_icon(work)
    title = work.title
    return title if work.github_repo.blank?

    github_icon = '<i class="bi bi-github" title="Linked to GitHub"></i>'
    sanitize("#{title} #{github_icon}")
  end
end
