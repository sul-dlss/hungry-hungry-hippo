import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  disable () {
    this.element.disabled = true
  }

  enable () {
    this.element.disabled = false
  }
}
