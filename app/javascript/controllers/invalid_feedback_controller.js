import { Controller } from '@hotwired/stimulus'

// Hides the invalid feedback message. This is useful for "standalone" invalid feedback messages that are not associated with a form input.
export default class extends Controller {
  static targets = ['feedback']
  static outlets = ['tab-error']
  static values = { tab: String }

  hide () {
    this.feedbackTargets.forEach(feedback => {
      feedback.classList.remove('d-block')
      feedback.classList.remove('is-invalid')
    })
    this.tabErrorOutlet.updateTabInvalidStatus(this.tabValue)
  }
}
