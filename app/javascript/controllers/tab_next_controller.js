import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { selector: String }

  show(event) {
    event.preventDefault();

    const triggerEl = document.querySelector(`#${this.selectorValue}`)
    bootstrap.Tab.getOrCreateInstance(triggerEl).show()
  }
}
