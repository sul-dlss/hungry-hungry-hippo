import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['description', 'input', 'value', 'sunetid', 'submitButton']

  connect () {
    this.change()
  }

  change () {
    if (this.valueTarget.value) {
      this.submitButtonTarget.disabled = false
      const [sunetid, description] = this.valueTarget.value.split(':')
      this.sunetidTarget.value = sunetid
      this.descriptionTarget.innerHTML = description
    }
  }

  disableSubmit() {
    if (this.inputTarget.value === '') {
      this.submitButtonTarget.disabled = true
      this.sunetidTarget.value = ''
      this.descriptionTarget.innerHTML = ''
      this.valueTarget.value = ''
    }
  }
}
