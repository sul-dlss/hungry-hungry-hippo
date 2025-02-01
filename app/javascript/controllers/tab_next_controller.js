import { Controller } from '@hotwired/stimulus'
import * as bootstrap from 'bootstrap' // eslint-disable-line no-unused-vars

export default class extends Controller {
  static values = { selector: String }

  show (event) {
    event.preventDefault()

    // get the current and next tabs
    const currentTab = document.querySelector(`#${this.selectorValue}`)
    const nextTab = currentTab.nextElementSibling

    bootstrap.Tab.getOrCreateInstance(nextTab).show() // eslint-disable-line no-undef
  }
}
