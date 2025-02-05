import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'enabledOption', 'reviewersSection'
  ]

  connect () {
    if (this.enabledOptionTarget.checked) {
      this.showReviewersSection()
    } else {
      this.hideReviewersSection()
    }
  }

  // Workflow toggle Reviewers selection
  showReviewersSection () {
    this.reviewersSectionTarget.classList.remove('d-none')
  }

  hideReviewersSection () {
    this.reviewersSectionTarget.classList.add('d-none')
  }
}
