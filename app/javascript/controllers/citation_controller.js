import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['autoGenerateCitation', 'citation']

  connect () {
    if (this.autoGenerateCitationTarget.checked) {
      this.disableCustomCitation()
    } else {
      this.enableCustomCitation()
    }
  }

  disableCustomCitation () {
    this.citationTarget.disabled = true
  }

  enableCustomCitation () {
    this.citationTarget.disabled = false
  }
}
