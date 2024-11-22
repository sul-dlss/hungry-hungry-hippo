import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { selector: String }

  show(event) {
    event.preventDefault();

    // get the current and next tabs
    const currentTab = document.querySelector(`#${this.selectorValue}`)
    const nextTab = currentTab.nextElementSibling

    bootstrap.Tab.getOrCreateInstance(nextTab).show()
  }
}
