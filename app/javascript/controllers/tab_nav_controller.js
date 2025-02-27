import { Controller } from '@hotwired/stimulus'
import * as bootstrap from 'bootstrap'

export default class extends Controller {
  static values = { tabId: String }

  showNext (event) {
    event.preventDefault()

    const nextTab = this.currentTab.nextElementSibling
    bootstrap.Tab.getOrCreateInstance(nextTab).show()
  }

  showPrevious (event) {
    event.preventDefault()

    const previousTab = this.currentTab.previousElementSibling
    bootstrap.Tab.getOrCreateInstance(previousTab).show()
  }

  get currentTab () {
    return document.querySelector(`#${this.tabIdValue}`)
  }
}
