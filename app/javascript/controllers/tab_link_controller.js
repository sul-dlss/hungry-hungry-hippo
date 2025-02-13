import { Controller } from '@hotwired/stimulus'
import * as bootstrap from 'bootstrap'

// Switches to a tab when the link is clicked.
// Provide the #id of the tab to switch to in the href attribute of the link.
export default class extends Controller {
  show (event) {
    event.preventDefault()

    const tabAnchor = this.element.getAttribute('href')
    bootstrap.Tab.getOrCreateInstance(tabAnchor).show() // eslint-disable-line no-undef
  }
}
