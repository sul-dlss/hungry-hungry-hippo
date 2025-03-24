import { Controller } from '@hotwired/stimulus'
import * as bootstrap from 'bootstrap'

export default class extends Controller {
  static targets = ['tab', 'pane', 'invalidDescription']

  connect () {
    // For each tab / pane pair, check if the pane contains an invalid input.
    // If it does, add the is-invalid class to the tab and modify the tab's
    // accessible label to include the error message.
    this.tabTargets.forEach((tabEl, index) => {
      const paneElement = this.paneTargets[index]
      const invalidElements = paneElement.querySelectorAll('.is-invalid')
      if (invalidElements.length > 0) {
        invalidElements.forEach(invalidElement => {
          invalidElement.addEventListener('change', event => {
            // Mark the invalid target that was changed as no longer invalid, *and* mark any other invalid field
            // with the same ID as no longer invalid. We think this is both harmless and it marks as valid the
            // first name and last name fields in the contributor form, which are duplicated due to their being
            // names in both the ORCID section and the non-ORCID section.
            const invalidFieldElements = paneElement.querySelectorAll(`#${event.currentTarget.id}`)
            if (invalidFieldElements) invalidFieldElements.forEach(element => element.classList.remove('is-invalid'))

            // Remove the invalid feedback divs corresponding to invalid fields that are changed.
            const invalidFeedbackElements = paneElement.querySelectorAll(`#${event.currentTarget.id}_error`)
            if (invalidFeedbackElements) invalidFeedbackElements.forEach(element => element.remove())

            // If the current pane no longer has fields marked as invalid, mark the tab as no longer
            // being invalid.
            if (!paneElement.querySelector('.is-invalid')) tabEl.classList.remove('is-invalid')
          })
        })
        tabEl.classList.add('is-invalid')
        const currentLabelledBy = tabEl.getAttribute('aria-labelledby')
        const newLabelledBy = `${currentLabelledBy} ${this.invalidDescriptionTarget.id}`
        tabEl.setAttribute('aria-labelledby', newLabelledBy)
      }
    })

    // Show the first tab that has an invalid input.
    const firstErrorTabEl = this.tabTargets.find(tabEl => tabEl.classList.contains('is-invalid'))
    if (firstErrorTabEl) {
      bootstrap.Tab.getOrCreateInstance(firstErrorTabEl).show() // eslint-disable-line no-undef
    }
  }

  clearInvalidStatus (paneAndTabId) {
    const tabElement = this.tabTargets.find(tab => tab.id === `${paneAndTabId}-tab`)
    const paneElement = this.paneTargets.find(pane => pane.id === `${paneAndTabId}-pane`)
    const invalidElements = paneElement.querySelectorAll('.is-invalid')
    if (invalidElements.length > 0) {
      invalidElements.forEach(invalidElement => {
        if (invalidElement.tagName === 'DIV') {
          invalidElement.remove()
        } else {
          invalidElement.classList.remove('is-invalid')
        }
      })
      tabElement.classList.remove('is-invalid')
    }
  }
}
