import { Controller } from '@hotwired/stimulus'

// Focuses the first invalid form input when the form is submitted with invalid inputs.
// This controller should be added to the form element.
export default class extends Controller {
  connect () {
    this.element.querySelector('.is-invalid')?.focus()
  }
}
