import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static outlets = ['tab-error']
  static targets = ['subtypeSection', 'workTypeRadio', 'workTypeHidden']

  connect () {
    if (this.hasWorkTypeHiddenTarget) this.showSubtypes({ target: this.workTypeHiddenTarget, skipClearingInvalidStatus: true })

    const checkedWorkTypeRadio = this.workTypeRadioTargets.find((radio) => radio.checked)
    if (checkedWorkTypeRadio) this.showSubtypes({ target: checkedWorkTypeRadio, skipClearingInvalidStatus: true })
  }

  showSubtypes (event) {
    const workType = event.target.value
    this.subtypeSectionTargets.forEach((section) => {
      const show = section.dataset.workType === workType
      section.classList.toggle('d-none', !show)
      // If the input is readonly, this indicates that should also be left disabled.
      section.querySelectorAll('input:not([readonly])').forEach((input) => {
        input.disabled = !show
        if (!show) input.checked = false
      })
    })
    if (!event.skipClearingInvalidStatus) this.clearInvalidStatus()
  }

  clearInvalidStatus () {
    this.tabErrorOutlet.clearInvalidStatus('types')
  }
}
