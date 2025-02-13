import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['releaseImmediate', 'releaseDuration']

  connect () {
    if (this.releaseImmediateTarget.checked) {
      this.resetReleaseDuration()
    } else {
      this.insertPromptOption()
    }
  }

  resetReleaseDuration () {
    // Reset the release_duration dropdown to a prompt, or create prompt if it does not exist
    const durationDropdown = this.releaseDurationTarget.querySelector('select')
    if (durationDropdown.querySelector('option[value=""]')) {
      durationDropdown.value = ''
      durationDropdown.selected = true
    } else { // the dropdown needs to be reset to show "Select an option"
      this.insertPromptOption()
    }
  }

  insertPromptOption () {
    // Prompt option is not included in the dropdown when loading a saved collection
    // or when fails validation so add it back for consistency, with appropriate selection.
    const durationDropdown = this.releaseDurationTarget.querySelector('select')
    const blankDuration = document.createElement('option')
    blankDuration.value = ''
    blankDuration.text = 'Select an option'
    blankDuration.selected = false
    if (this.releaseImmediateTarget.checked) {
      blankDuration.selected = true
    } else if (durationDropdown.classList.contains('is-invalid')) {
      blankDuration.selected = true
    }
    durationDropdown.insertBefore(blankDuration, durationDropdown.firstChild)
  }
}
