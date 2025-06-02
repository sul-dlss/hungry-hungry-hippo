import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static outlets = ['dropzone']

  // Called by dropzone controller after queue is complete so that Your files and globus sections can be reloaded.
  reload () {
    this.element.reload()
  }

  disableDropzone () {
    if (this.hasDropzoneOutlet) this.dropzoneOutlet.disable()
  }

  enableDropzone () {
    if (this.hasDropzoneOutlet) this.dropzoneOutlet.enable()
  }
}
