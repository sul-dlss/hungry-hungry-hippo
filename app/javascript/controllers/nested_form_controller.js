import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["container", "instance", "template"]

  add(event) {
    event.preventDefault()

    this.containerTarget.insertAdjacentHTML(
      'beforeend',
      this.templateTarget.innerHTML.replace(/NEW_RECORD/g, this.maxIndex + 1)
    )
  }

  get maxIndex() {
    return Math.max(-1, ...this.instanceTargets.map((instance) => parseInt(instance.dataset.index)))
  }
}
