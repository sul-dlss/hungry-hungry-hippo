import { Controller } from '@hotwired/stimulus'
import Dropzone from 'dropzone'

export default class extends Controller {
  static outlets = ['dropzone-files', 'tab-error']
  static targets = ['progress', 'error', 'folderAlert', 'folderAlertText']
  static values = {
    existingFiles: { type: Number, default: 0 },
    maxFiles: Number,
    maxFilesize: Number,
    ahoy: { type: Boolean, default: false }, // If true, ahoy will track file uploads
    formId: String
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
    this.basePath = null
    this.dropzone.on('processingmultiple', () => {
      this.element.dataset.dropzoneReady = false
      // Using processingmultiple instead of addedfiles for showing the progress bar
      // since addedfiles is triggered by dropping an empty directory.
      // This is not.
      this.progressTarget.classList.remove('d-none')
      // This shows the user that something is going on since there may be a paused before first progress.
      this.updateProgress(2)

      // This notifies the unsaved changes controller that the form has changed.
      this.element.dispatchEvent(new Event('change'))

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
      // Reload the files section to show the newly uploaded files.
      this.dropzoneFilesOutlets.forEach(dropzoneFiles => dropzoneFiles.reload())
      if (this.hasTabErrorOutlet) this.tabErrorOutlet.clearInvalidStatus('files')
      // If ahoy is enabled, track the file upload completion.
      if (this.ahoyValue) { ahoy.track('files uploaded', { form_id: this.formIdValue }) } // eslint-disable-line no-undef
      this.element.dataset.dropzoneReady = true
    })
    this.dropzone.on('sendingmultiple', (files, xhr, data) => {
      // Add the full path of each file to the form data
      for (let i = 0; i < files.length; i++) {
        const file = files[i]
        let path = file.fullPath ? file.fullPath : file.name
        // this.basePath is set when the user selects a folder to upload to.
        if (this.basePath) path = `${this.basePath}/${path}`
        data.append(`content[paths][${i}]`, path)
      }
    })
    this.dropzone.on('errormultiple', (files, message) => {
      this.clearErrors()

      this.errorTarget.classList.remove('d-none')
      files.forEach(file => {
        const errorElement = document.createElement('li')
        console.log(message)
        errorElement.textContent = `${file.name}: ${message.error}`
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

  setBasePath (basePath) {
    this.basePath = basePath
    this.folderAlertTextTarget.textContent = `Files will be uploaded to ${basePath} folder.`
    this.folderAlertTarget.classList.remove('d-none')
    this.element.scrollIntoView()
    this.element.focus()
  }

  clearBasePath () {
    this.basePath = null
    this.folderAlertTarget.classList.add('d-none')
  }

  disable () {
    this.element.classList.add('opacity-50')
    this.dropzone.disable()
    this.element.dataset.dropzoneReady = false
  }

  enable () {
    this.element.classList.remove('opacity-50')
    this.dropzone.enable()
    this.element.dataset.dropzoneReady = true
  }
}
