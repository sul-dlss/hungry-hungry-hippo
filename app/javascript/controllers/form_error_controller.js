import { Controller } from '@hotwired/stimulus'

// Clears invalid status from inputs when the inputs are changed.
// See app/views/articles/form.html.erb for how this controller is used.
export default class extends Controller {
  static targets = ['filesInvalidFeedback']

  changed (event) {
    console.log(event)
    const target = event.target
    if (!target.classList.contains('is-invalid')) return
    target.classList.remove('is-invalid')

    // Remove the invalid feedback divs corresponding to invalid fields that are changed.
    const invalidFeedbackElements = document.querySelectorAll(`#${target.id}_error`)
    if (invalidFeedbackElements) invalidFeedbackElements.forEach(element => element.remove())
  }

  // Called by the dropzone controller when files are uploaded successfully to clear any file upload errors.
  changedFiles () {
    if (this.hasFilesInvalidFeedbackTarget) this.filesInvalidFeedbackTarget.remove()
  }
}
