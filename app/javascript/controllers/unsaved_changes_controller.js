import { Controller } from '@hotwired/stimulus'

const LEAVING_PAGE_MESSAGE = 'Are you sure you want to leave this page? Your changes will not be saved.'

export default class extends Controller {
  // This should be added on page around all forms that need to be tracked:
  // <div data-controller="unsaved-changes" data-action="change->unsaved-changes#changed beforeunload@window->unsaved-changes#leavingPage turbo:before-visit@window->unsaved-changes#leavingPage">

  // This should be added to any form that needs to be tracked:
  // <form action="change->unsaved-changes#changed">

  // Also, for any inputs (like trix-editor) that don't trigger to the change event, unsaved-changes#changed needs to be called:
  // <trix-editor data-action="trix-change->unsaved-changes#changed">

  // Also, unsaved-changes#allowFormSubmission should be called for any submit or cancel buttons:
  // <input type="submit" data-action="unsaved-changes#allowFormSubmission">
  connect () {
    this.allowSubmit = true
  }

  changed (event) {
    this.allowSubmit = false
  }

  leavingPage (event) {
    if (this.allowSubmit) return

    if (event.type === 'turbo:before-visit') {
      if (!window.confirm(LEAVING_PAGE_MESSAGE)) {
        event.preventDefault()
      }
    } else {
      event.returnValue = LEAVING_PAGE_MESSAGE
      return event.returnValue
    }
  }

  allowFormSubmission (event) {
    this.allowSubmit = true
  }
}
