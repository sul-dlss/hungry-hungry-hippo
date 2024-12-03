import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['year', 'month', 'day']
  
  connect() {
    this.update();
  }

  update() {
    // Disable month and day fields if year is empty
    // Disable day field if month is empty
    this.monthTarget.disabled = false
    this.dayTarget.disabled = false
    if (this.yearTarget.value === '') {
      this.monthTarget.disabled = true
      this.dayTarget.disabled = true
    } else if (this.monthTarget.value === '') {
      this.dayTarget.disabled = true
    }
  }

  reset() {
    this.yearTarget.value = ''
    this.monthTarget.value = ''
    this.dayTarget.value = ''
    this.update()
  }
}