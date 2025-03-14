import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['subtypeSection', 'workTypeRadio', 'workTypeHidden']

  connect () {
    if (this.hasWorkTypeHiddenTarget) this.showSubtypes({ target: this.workTypeHiddenTarget })

    const checkedWorkTypeRadio = this.workTypeRadioTargets.find((radio) => radio.checked)
    if (checkedWorkTypeRadio) this.showSubtypes({ target: checkedWorkTypeRadio })
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
  }
}
