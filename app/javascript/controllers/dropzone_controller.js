import { Controller } from '@hotwired/stimulus'
import Dropzone from 'dropzone'

export default class extends Controller {
  static targets = ['progress']

  connect () {
    this.dropzone = new Dropzone(this.element, {
      paramName: 'content[files]',
      uploadMultiple: true,
      createImageThumbnails: false,
      addRemoveLinks: false,
      disablePreviews: true,
      maxFilesize: 10000 // 10GB
    })
    this.progress = 0
    this.dropzone.on('addedfiles', () => {
      this.progressTarget.classList.remove('d-none')
      // This shows the user that something is going on since there may be a paused before first progress.
      this.updateProgress(2)
    })
    this.dropzone.on('totaluploadprogress', (totalUploadProgress) => {
      const uploadProgress = Math.trunc(totalUploadProgress)
      this.updateProgress(uploadProgress)
    })
    this.dropzone.on('queuecomplete', async () => {
      // Give the user a second to process the 100% progress
      await new Promise(resolve => setTimeout(resolve, 1000))
      this.dropzone.element.classList.remove('dz-started')
      this.progressTarget.classList.add('d-none')
      this.updateProgress(0)
    })
  }

  updateProgress (progress) {
    // For some reason progress bounces around a bit. This keeps the progress moving forward.
    if (progress <= this.progress) return

    this.progressTarget.setAttribute('aria-valuenow', progress)
    const barElement = this.progressTarget.querySelector('.progress-bar')
    barElement.style.width = `${progress}%`
    this.progress = progress
  }
}
