import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['uri', 'value']

  change () {
    if (this.valueTarget.value) {
      this.uriTarget.value = this.valueTarget.value
    }
  }
}
