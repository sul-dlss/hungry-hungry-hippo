import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { selector: String }

  show(event) {
    event.preventDefault();

    const tabsOrder = ["title", "abstract", "related_content", "deposit"]
    const nextTabIndex = tabsOrder.indexOf(this.selectorValue) + 1
    const nextTab = tabsOrder[nextTabIndex]

    const triggerEl = document.querySelector(`#${nextTab}-tab`)
    bootstrap.Tab.getOrCreateInstance(triggerEl).show()
  }
}
