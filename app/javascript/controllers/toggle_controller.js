import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'leftRadio', 'rightRadio', 'leftLabel', 'rightLabel'
  ]

  connect () {
    if (this.leftRadioTarget.checked) {
      this.leftSelected()
    } else {
      this.rightSelected()
    }
  }

  leftSelected () {
    this.selectRadio(this.leftRadioTarget, this.leftLabelTarget)
    this.unselectRadio(this.rightRadioTarget, this.rightLabelTarget)
  }

  rightSelected () {
    this.selectRadio(this.rightRadioTarget, this.rightLabelTarget)
    this.unselectRadio(this.leftRadioTarget, this.leftLabelTarget)
  }

  selectRadio (radioEl, labelEl) {
    radioEl.checked = true
    labelEl.classList.replace('btn-outline-primary', 'btn-primary')
  }

  unselectRadio (radioEl, labelEl) {
    radioEl.checked = false
    labelEl.classList.replace('btn-primary', 'btn-outline-primary')
  }
}
