import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static values = {
    ahoy: { type: Boolean, default: false },
    formId: String
  }
  // This should be added on page around all forms that need to be tracked:
  // <div data-controller="ahoy-form-changes" data-action="change->ahoy-form-changes#changed" data-ahoy-form-changes-form-id-value="<form id>" data-ahoy-form-changes-ahoy-value="true">

  // This should be added to any form that needs to be tracked:
  // <form action="change->ahoy-form-changes#changed">

  // Also, for any inputs (like trix-editor) that don't trigger to the change event, ahoy-form-changes#changed needs to be called:
  // <trix-editor data-action="trix-change->ahoy-form-changes#changed">
  changed (event) {
    if (this.ahoyValue) {
      ahoy.track('form changed', { form_id: this.formIdValue, field: event.target.name }) // eslint-disable-line no-undef
    }
  }
}
