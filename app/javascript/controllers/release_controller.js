import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['releaseImmediate', 'releaseDuration']

  connect () {
    if (this.releaseImmediateTarget.checked) {
      this.resetReleaseDuration()
    }
  }

  resetReleaseDuration () {
    // If the release_option radio button selection is "immediate",
    // the release_duration field should be reset to empty and a prompt.
    const durationDropdown = this.releaseDurationTarget.querySelector('select')
    if (durationDropdown.querySelector('option[value=""]')) {
      durationDropdown.value = ''
    } else { // the dropdown needs to be reset to show "Select an option"
      const blankDuration = document.createElement('option')
      blankDuration.value = ''
      blankDuration.text = 'Select an option'
      blankDuration.selected = true
      durationDropdown.insertBefore(blankDuration, durationDropdown.firstChild)
    }
  }
}
