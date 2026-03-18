import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['spinner', 'formSection', 'extractedAbstract']
  static values = { doi: String }

  showSpinner (event) {
    this.formSectionTarget.classList.add('d-none')
    this.spinnerTarget.classList.remove('d-none')
  }

  clearExtracted () {
    this.extractedAbstractTarget.value = ''

    ahoy.track('extracted abstract cleared', { doi: this.doiValue }) // eslint-disable-line no-undef
  }
}
