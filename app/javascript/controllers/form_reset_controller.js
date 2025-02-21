import { Controller } from '@hotwired/stimulus'

// Put this on a form for the form to be reset when rendered.
export default class extends Controller {
  connect () {
    this.element.reset()
  }
}
