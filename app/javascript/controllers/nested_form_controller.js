import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['container', 'instance', 'template']
  static values = { selector: String }

  add (event) {
    if (event) event.preventDefault()

    this.containerTarget.insertAdjacentHTML(
      'beforeend',
      this.templateTarget.innerHTML.replace(/NEW_RECORD/g, this.maxIndex + 1)
    )
  }

  delete (event) {
    event.preventDefault()

    event.target.closest(this.selectorValue).remove()
    if (this.instanceTargets.length === 0) this.add()
  }

  get maxIndex () {
    return Math.max(-1, ...this.instanceTargets.map((instance) => parseInt(instance.dataset.index)))
  }
}
