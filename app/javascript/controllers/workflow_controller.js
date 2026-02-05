import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = [
    'enabledOption', 'reviewersSection'
  ]

  static outlets = ['participants']

  connect () {
    if (this.enabledOptionTarget.checked) {
      this.showReviewersSection()
    } else {
      this.hideReviewersSection()
    }
  }

  // Workflow toggle Reviewers selection
  showReviewersSection () {
    this.reviewersSectionTarget.classList.remove('d-none')
    if (this.hasParticipantsOutlet && this.participantsOutlet.isEmpty()) {
      this.getManagers().forEach(manager => this.participantsOutlet.addParticipant(manager))
    }
  }

  hideReviewersSection () {
    this.reviewersSectionTarget.classList.add('d-none')
  }

  getManagers () {
    const managerSunetIdInputs = document.querySelectorAll('input[name^="collection[managers_attributes]"][name$="[sunetid]"]')
    return Array.from(managerSunetIdInputs).map(input => {
      const baseName = input.name.replace('[sunetid]', '')
      const nameInput = document.querySelector(`input[name="${baseName}[name]"]`)
      return {
        sunetid: input.value,
        name: nameInput ? nameInput.value : ''
      }
    }).filter(m => m.sunetid !== '')
  }
}
