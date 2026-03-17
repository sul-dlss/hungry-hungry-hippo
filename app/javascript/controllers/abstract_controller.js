import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['spinner', 'formSection', 'extractedAbstract']
  static values = { clearAbstractsPath: String }

  showSpinner (event) {
    this.formSectionTarget.classList.add('d-none')
    this.spinnerTarget.classList.remove('d-none')
  }

  clearExtracted () {
    this.extractedAbstractTarget.value = ''

    // this calls the server to record the event
    fetch(this.clearAbstractsPathValue, {
      method: 'GET',
      credentials: 'same-origin',
      keepalive: true
    })
  }
}
