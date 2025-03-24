import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static outlets = ['tab-error']
  static targets = ['year', 'month', 'day', 'approximate']

  connect () {
    this.update({ skipClearingInvalidStatus: true })
  }

  update (event) {
    // Disable month and day fields if year is empty
    // Disable day field if month is empty
    // Disable approximate checkbox if day field
    // Disable day field if approximate checkbox is checked
    this.monthTarget.disabled = false
    this.dayTarget.disabled = false
    if (this.yearTarget.value === '') {
      this.monthTarget.disabled = true
      this.dayTarget.disabled = true
    } else if (this.monthTarget.value === '') {
      this.dayTarget.disabled = true
    }
    if (!this.hasApproximateTarget) return
    this.approximateTarget.disabled = this.dayTarget.value !== ''
    this.dayTarget.disabled = this.dayTarget.disabled || this.approximateTarget.checked

    if (!event?.skipClearingInvalidStatus) this.tabErrorOutlet.clearInvalidStatus('dates')
  }

  reset () {
    this.yearTarget.value = ''
    this.monthTarget.value = ''
    this.dayTarget.value = ''
    if (this.hasApproximateTarget) this.approximateTarget.checked = false
    this.update()
  }
}
