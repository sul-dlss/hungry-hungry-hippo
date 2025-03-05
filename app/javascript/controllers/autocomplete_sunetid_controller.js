import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['lookup', 'input', 'sunetidInput', 'nameInput']

  change () {
    // This hides the sunetid lookup and show the input field when an account is selected.
    // It also update hidden inputs with name and sunetid values.
    if (this.inputTarget.value !== '') {
      this.lookupTarget.classList.add('d-none')
      this.inputTarget.classList.remove('d-none')
      const [sunetId, name] = this.inputTarget.value.split(': ')
      this.sunetidInputTarget.value = sunetId
      this.nameInputTarget.value = name
    }
  }
}
