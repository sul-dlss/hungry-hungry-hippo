import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['autoGenerateCitation', 'customCitation', 'citation']

  connect () {
    if (this.autoGenerateCitationTarget.checked) {
      this.autoGenerateCitationSelected()
    } else {
      this.customCitationSelected()
    }
  }

  autoGenerateCitationSelected () {
    this.citationTarget.disabled = true
  }

  customCitationSelected () {
    this.citationTarget.disabled = false
  }
}
