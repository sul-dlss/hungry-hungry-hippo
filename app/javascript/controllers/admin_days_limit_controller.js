import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['daysLimit']

  connect () {
    if (this.daysLimitTarget.changed) {
      console.log("Days limit has changed, resetting to prompt option.")
    }
  }
}
