import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['subtypeSection', 'workTypeRadio']

  connect () {
    const checkedWorkTypeRadio = this.workTypeRadioTargets.find((radio) => radio.checked)
    if (checkedWorkTypeRadio) this.showSubtypes({ target: checkedWorkTypeRadio })
  }

  showSubtypes (event) {
    const workType = event.target.value
    this.subtypeSectionTargets.forEach((section) => {
      const show = section.dataset.workType === workType
      section.classList.toggle('d-none', !show)
      section.querySelectorAll('input').forEach((input) => { input.disabled = !show })
    })
  }
}
