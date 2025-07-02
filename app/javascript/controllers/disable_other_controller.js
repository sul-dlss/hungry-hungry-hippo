import { Controller } from '@hotwired/stimulus'

// Disable other targets
export default class extends Controller {
  static targets = ['other']

  connect () {
    console.debug('DisableOtherController connected', this.otherTargets)
  }

  disable (event) {
    this.otherTargets.forEach((target) => {
      if (target !== event.target) {
        target.disabled = true
        target.classList.add('disabled')
      }
    })
  }
}
