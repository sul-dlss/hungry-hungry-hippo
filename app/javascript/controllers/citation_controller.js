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
    console.log('autoGenerateCitation selected')
    this.citationTarget.disabled = true
  }

  customCitationSelected () {
    console.log('customCitation selected')
    this.citationTarget.disabled = false
  }
}
