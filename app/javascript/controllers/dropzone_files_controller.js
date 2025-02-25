import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  // Called by dropzone controller after queue is complete so that Your files section can be reloaded.
  reload () {
    this.element.reload()
  }
}
