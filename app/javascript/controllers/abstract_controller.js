import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['spinner', 'formSection']

  showSpinner (event) {
    this.formSectionTarget.classList.add('d-none')
    this.spinnerTarget.classList.remove('d-none')
  }
}
