import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['lookup', 'input']

  change () {
    // This hides the sunetid lookup and show the input field when an account is selected.
    if (this.inputTarget.value !== '') {
      this.lookupTarget.classList.add('d-none')
      this.inputTarget.classList.remove('d-none')
    }
  }
}
