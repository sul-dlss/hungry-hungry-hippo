import { Controller } from '@hotwired/stimulus'

export default class extends Controller {
  static targets = ['instance', 'container']

  connect () {
    this.adjustActions()
  }

  instanceTargetConnected () {
    this.adjustActions()
  }

  instanceTargetDisconnected () {
    this.adjustActions()
  }

  adjustActions () {
    if (!this.hasContainerTarget) return
    this.containerTarget.querySelectorAll('.form-instance').forEach((instanceEl, index) => {
      instanceEl.querySelectorAll('.move-up').forEach((btnEl) => btnEl.classList.toggle('d-none', index === 0))
      instanceEl.querySelectorAll('.move-down').forEach((btnEl) => btnEl.classList.toggle('d-none', index === this.instanceTargets.length - 1))
    })
  }

  moveUp (event) {
    event.preventDefault()
    const instanceEl = event.target.closest('.form-instance')
    const previousInstanceEl = instanceEl.previousElementSibling
    if (previousInstanceEl) {
      this.containerTarget.insertBefore(instanceEl, previousInstanceEl)
      this.adjustActions()
    }
  }

  moveDown (event) {
    event.preventDefault()
    const instanceEl = event.target.closest('.form-instance')
    const nextInstanceEl = instanceEl.nextElementSibling
    if (nextInstanceEl) {
      this.containerTarget.insertBefore(nextInstanceEl, instanceEl)
      this.adjustActions()
    }
  }
}
