import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['radio']
  connect () {
    this.radioTargets.forEach((radio) => {
      if (radio.checked) {
        this.toggle({ target: radio })
      }
    })
  }

  toggle (event) {
    const radioElem = event.target
    this.disableInputs(radioElem, false)
    this.radioTargets.forEach((radio) => {
      if (radio !== radioElem) {
        this.disableInputs(radio, true)
      }
    })
  }

  disableInputs (radioElem, disable) {
    const containerElem = radioElem.closest('.form-check')
    const inputs = containerElem.querySelectorAll('input, select, textarea')
    inputs.forEach((input) => {
      if (!this.radioTargets.includes(input)) {
        input.disabled = disable
      }
    })
    // Elements that have radio-hide class will be hidden when the radio is not selected.
    const hideEls = containerElem.querySelectorAll('.radio-hide')
    hideEls.forEach((el) => {
      el.classList.toggle('d-none', disable)
    })
    // Elements that have radio-show class will be shown when the radio is not selected.
    const showEls = containerElem.querySelectorAll('.radio-show')
    showEls.forEach((el) => {
      el.classList.toggle('d-none', !disable)
    })
  }
}
