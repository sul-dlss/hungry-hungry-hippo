import { Controller } from '@hotwired/stimulus'

// Disable other targets
export default class extends Controller {
  static targets = ['other']

  disable (event) {
    this.otherTargets.forEach((target) => {
      if (target !== event.target) {
        target.disabled = true
        target.classList.add('disabled')
      }
    })
  }
}
