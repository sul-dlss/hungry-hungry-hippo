import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = { path: String }
  static outlets = ['dropzone']

  setBasePath (event) {
    event.preventDefault()
    event.stopPropagation()
    // Pass on to dropzone controller.
    this.dropzoneOutlets.forEach(dropzone => dropzone.setBasePath(this.pathValue))
  }
}
