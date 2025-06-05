import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['daysLimit']

  change (event) {
    event.target.form.requestSubmit()
  }
}
