import { Controller } from '@hotwired/stimulus'

// For toggling creation dates between single and range
export default class extends Controller {
  static targets = ['singleDateContainer', 'rangeDateContainer', 'singleDateRadio']

  connect () {
    if (this.singleDateRadioTarget.checked) {
      this.selectSingle()
    } else {
      this.selectRange()
    }
  }

  selectSingle () {
    this.hide(this.rangeDateContainerTarget)
    this.show(this.singleDateContainerTarget)
  }

  selectRange () {
    this.hide(this.singleDateContainerTarget)
    this.show(this.rangeDateContainerTarget)
  }

  show (containerEl) {
    containerEl.classList.remove('d-none')
  }

  hide (containerEl) {
    containerEl.classList.add('d-none')
  }
}
