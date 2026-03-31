import { Controller } from '@hotwired/stimulus'

// Connects to data-controller="recaptcha"
export default class extends Controller {
  // Target for the `RecaptchaComponent`, which contains the data attributes for action & siteKey
  static targets = ['tags']

  async refresh (event) {
    // The recaptcha tags aren't always rendered (e.g., if a user is logged in).
    if (!this.isRecaptchaEnabled()) return

    const el = this.recaptchaElement()
    if (el?.value) return // token already set, let form submit through

    event.preventDefault()
    await this.execute()

    event.target.requestSubmit()
  }

  isRecaptchaEnabled () {
    return !!this.hasTagsTarget
  }

  recaptchaElement () {
    const action = this.action().replace('_', '-')
    const recaptchaId = `g-recaptcha-response-data-${action}`
    return document.getElementById(recaptchaId)
  }

  action () {
    return this.tagsTarget.getAttribute('data-recaptcha-action-value')
  }

  siteKey () {
    return this.tagsTarget.getAttribute('data-recaptcha-site-key-value')
  }

  async execute () {
    const recaptchaElement = this.recaptchaElement()
    if (!recaptchaElement || typeof grecaptcha === 'undefined') return

    const response = await grecaptcha.execute(this.siteKey(), { action: this.action() }) // eslint-disable-line no-undef
    if (response) recaptchaElement.value = response
  }
}
