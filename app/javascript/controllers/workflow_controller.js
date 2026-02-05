import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'reviewEnabledOption', 'reviewDisabledOption', 'reviewersSection',
    'articleEnabledOption', 'articleDisabledOption',
    'githubEnabledOption', 'githubDisabledOption'
  ]

  connect () {
    this.toggleWorkflows()
  }

  toggleWorkflows () {
    if (this.reviewEnabledOptionTarget.checked) {
      this.showReviewersSection()
      this.toggleArticleAndGithubWorkflows(true)
    } else {
      this.hideReviewersSection()
      this.toggleArticleAndGithubWorkflows(false)
    }
    if (this.articleEnabledOptionTarget.checked || this.githubEnabledOptionTarget.checked) {
      this.toggleReviewWorkflow(true)
    } else {
      this.toggleReviewWorkflow(false)
    }
  }

  // Workflow toggle Reviewers selection
  showReviewersSection () {
    this.reviewersSectionTarget.classList.remove('d-none')
  }

  hideReviewersSection () {
    this.reviewersSectionTarget.classList.add('d-none')
  }

  toggleReviewWorkflow (disable) {
    this.reviewEnabledOptionTarget.disabled = disable
    this.reviewDisabledOptionTarget.disabled = disable
  }

  toggleArticleAndGithubWorkflows (disable) {
    this.articleEnabledOptionTarget.disabled = disable
    this.articleDisabledOptionTarget.disabled = disable
    this.githubEnabledOptionTarget.disabled = disable
    this.githubDisabledOptionTarget.disabled = disable
  }
}
