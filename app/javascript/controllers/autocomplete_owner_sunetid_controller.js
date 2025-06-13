import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['input', 'value', 'sunetid', 'submitButton']

  connect () {
    this.change()
  }

  change () {
    if (this.valueTarget.value) {
      this.submitButtonTarget.disabled = false
      this.sunetidTarget.value = this.valueTarget.value
    }
  }

  disableSubmit () {
    if (this.inputTarget.value === '') {
      this.submitButtonTarget.disabled = true
      this.sunetidTarget.value = ''
      this.valueTarget.value = ''
    }
  }
}
