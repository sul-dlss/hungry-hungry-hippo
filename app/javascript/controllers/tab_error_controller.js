import { Controller } from '@hotwired/stimulus'
import * as bootstrap from 'bootstrap'

export default class extends Controller {
  static targets = ['tab', 'pane']

  connect () {
    // For each tab / pane pair, check if the pane contains an invalid input.
    // If it does, add the is-invalid class to the tab.
    this.tabTargets.forEach((tabEl, index) => {
      const paneEl = this.paneTargets[index]
      if (paneEl.querySelector('.is-invalid')) {
        tabEl.classList.add('is-invalid')
        tabEl.setAttribute('aria-description', 'Error: required fields missing')
      } else {
        tabEl.classList.remove('is-invalid')
        tabEl.removeAttribute('aria-description')
      }
    })
    // Show the first tab that has an invalid input.
    const firstErrorTabEl = this.tabTargets.find(tabEl => tabEl.classList.contains('is-invalid'))
    if (firstErrorTabEl) {
      bootstrap.Tab.getOrCreateInstance(firstErrorTabEl).show() // eslint-disable-line no-undef
    }
  }
}
