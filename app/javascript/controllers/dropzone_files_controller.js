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

  disableDropzoneConfirm (event) {
    if (this.hasDropzoneOutlet) {
      if (window.confirm('Once your Globus file transfer is complete, the files on Globus will replace the files currently in the deposit.')) {
        this.dropzoneOutlet.disable()
      } else {
        event.preventDefault()
      }
    }
  }

  enableDropzone () {
    if (this.hasDropzoneOutlet) this.dropzoneOutlet.enable()
  }
}
