import { Controller } from '@hotwired/stimulus'
import Dropzone from 'dropzone'

export default class extends Controller {
  static targets = ['progress', 'error']
  static values = {
    existingFiles: { type: Number, default: 0 },
    maxFiles: Number,
    maxFilesize: Number

  }

  // Expected error handling behavior:
  // - A blank directory is ignored.
  // - Files that are larger than maxFilesize will not be uploaded.
  // - Only maxFiles files are accepted. This includes existing files.
  // - For each file that is not accepted, an error message is shown.
  // - Error messages are cleared when the next file is added.

  connect () {
    this.dropzone = new Dropzone(this.element, {
      paramName: 'content[files]',
      uploadMultiple: true,
      createImageThumbnails: false,
      addRemoveLinks: false,
      disablePreviews: true,
      maxFilesize: this.maxFilesizeValue,
      maxFiles: this.maxFilesValue - this.existingFilesValue
    })
    this.progress = 0
    this.shouldClearErrors = false
    this.dropzone.on('processingmultiple', () => {
      // Using processingmultiple instead of addedfiles for showing the progress bar
      // since addedfiles is triggered by dropping an empty directory.
      // This is not.
      this.progressTarget.classList.remove('d-none')
      // This shows the user that something is going on since there may be a paused before first progress.
      this.updateProgress(2)

      this.clearErrors()
    })
    this.dropzone.on('totaluploadprogress', (totalUploadProgress) => {
      const uploadProgress = Math.trunc(totalUploadProgress)
      this.updateProgress(uploadProgress)
    })
    this.dropzone.on('queuecomplete', async () => {
      this.shouldClearErrors = true
      // Give the user a second to process the 100% progress
      await new Promise(resolve => setTimeout(resolve, 1000))
      this.dropzone.element.classList.remove('dz-started')
      this.progressTarget.classList.add('d-none')
      this.updateProgress(0, true)
    })
    this.dropzone.on('sendingmultiple', (files, xhr, data) => {
      // Add the full path of each file to the form data
      for (let i = 0; i < files.length; i++) {
        const file = files[i]
        const path = file.fullPath ? file.fullPath : file.name
        data.append(`content[paths][${i}]`, path)
      }
      data.append('content[completed]', this.dropzone.getActiveFiles().length === files.length)
    })
    this.dropzone.on('errormultiple', (files, message) => {
      this.clearErrors()

      this.errorTarget.classList.remove('d-none')
      files.forEach(file => {
        const errorElement = document.createElement('li')
        errorElement.textContent = `${file.name}: ${message}`
        this.errorTarget.appendChild(errorElement)
      })
    })
  }

  // Clear errors if this is the first error in the batch.
  clearErrors () {
    if (!this.shouldClearErrors) return
    this.errorTarget.innerHTML = ''
    this.shouldClearErrors = false
  }

  updateProgress (progress, reset = false) {
    // For some reason progress bounces around a bit. This keeps the progress moving forward.
    if (progress <= this.progress && !reset) return

    this.progressTarget.setAttribute('aria-valuenow', progress)
    const barElement = this.progressTarget.querySelector('.progress-bar')
    barElement.style.width = `${progress}%`
    this.progress = progress
  }
}
