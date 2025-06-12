import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['description', 'input', 'name', 'value', 'sunetid', 'submitButton']

  connect () {
    this.change()
  }

  change () {
    if (this.valueTarget.value) {
      this.submitButtonTarget.disabled = false
      const [sunetid, description] = this.valueTarget.value.split(': ')
      const [name, _department] = description.split(' - ') // eslint-disable-line no-unused-vars
      this.sunetidTarget.value = sunetid
      this.nameTarget.value = name
      this.descriptionTarget.innerHTML = description
    }
  }

  disableSubmit () {
    if (this.inputTarget.value === '') {
      this.submitButtonTarget.disabled = true
      this.sunetidTarget.value = ''
      this.nameTarget.value = ''
      this.descriptionTarget.innerHTML = ''
      this.valueTarget.value = ''
    }
  }
}
