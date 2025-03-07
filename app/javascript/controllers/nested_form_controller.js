import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['container', 'instance', 'template']
  static values = {
    selector: String,
    addWhenEmpty: Boolean
  }

  add (event) {
    if (event) event.preventDefault()

    const newIndex = this.maxIndex + 1
    this.containerTarget.insertAdjacentHTML(
      'beforeend',
      this.templateTarget.innerHTML.replace(/NEW_RECORD/g, newIndex)
    )
    return this.element.querySelector(`${this.selectorValue}[data-index="${newIndex}"]`)
  }

  delete (event) {
    event.preventDefault()

    event.target.closest(this.selectorValue).remove()
    if (this.instanceTargets.length === 0 && this.addWhenEmptyValue) this.add()
  }

  get maxIndex () {
    return Math.max(-1, ...this.instanceTargets.map((instance) => parseInt(instance.dataset.index)))
  }
}
